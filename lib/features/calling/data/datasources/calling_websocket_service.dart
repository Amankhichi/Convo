import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:convo/app/config/calling_config.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/calling/data/models/signaling_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WsConnectionState { disconnected, connecting, connected }

class CallingWebSocketService {
  final SecureStorage _secureStorage;
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  final _messageController = StreamController<SignalingMessageModel>.broadcast();
  final _connectionStateController = StreamController<WsConnectionState>.broadcast();

  WsConnectionState _connectionState = WsConnectionState.disconnected;
  WsConnectionState get connectionState => _connectionState;

  Stream<SignalingMessageModel> get messageStream => _messageController.stream;
  Stream<WsConnectionState> get connectionStateStream => _connectionStateController.stream;

  bool _isDisposed = false;
  bool _manualDisconnect = false;

  // Reconnect logic
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _baseDelayMs = 1000;
  static const int _maxDelayMs = 30000;

  CallingWebSocketService(this._secureStorage);

  Future<void> connect() async {
    if (_isDisposed) return;
    if (_connectionState == WsConnectionState.connected ||
        _connectionState == WsConnectionState.connecting) {
      return;
    }

    final token = _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      _log("Cannot connect Calling WebSocket: JWT token is missing");
      _updateState(WsConnectionState.disconnected);
      return;
    }

    _manualDisconnect = false;
    _updateState(WsConnectionState.connecting);

    // 1. Force WebSocket protocol scheme (ws:// or wss://)
    var wsBaseUrl = CallingConfig.effectiveWsUrl.split('#').first.trim();
    if (wsBaseUrl.startsWith('http://')) {
      wsBaseUrl = wsBaseUrl.replaceFirst('http://', 'ws://');
    } else if (wsBaseUrl.startsWith('https://')) {
      wsBaseUrl = wsBaseUrl.replaceFirst('https://', 'wss://');
    }

    // 2. Clean token parameter strictly
    String cleanToken = token.trim().replaceAll(RegExp(r'[\s\r\n\t]+'), '').replaceAll('#', '');
    if (cleanToken.contains('#')) {
      cleanToken = cleanToken.split('#').first;
    }

    // 3. Construct clean Uri directly without fragment
    final parsedBase = Uri.parse(wsBaseUrl).removeFragment();
    final scheme = (parsedBase.scheme == 'wss' || wsBaseUrl.startsWith('wss://')) ? 'wss' : 'ws';
    final host = parsedBase.host;
    final port = parsedBase.port;
    final path = parsedBase.path;

    final queryParams = Map<String, String>.from(parsedBase.queryParameters);
    queryParams['token'] = cleanToken;

    final finalUri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: queryParams,
    ).removeFragment();

    final cleanUrlString = finalUri.toString().split('#').first;

    final userId = _secureStorage.getUserId();
    _log("[WEBSOCKET-CONNECT] Final Sanitized WebSocket URL: $cleanUrlString (userId=$userId)");

    try {
      _channel = WebSocketChannel.connect(finalUri);

      // Listen to incoming messages
      _channelSubscription = _channel!.stream.listen(
        (dynamic data) {
          _onDataReceived(data);
        },
        onError: (dynamic error) {
          _log("[CALL-DEBUG] WebSocket error: $error");
          _handleDisconnect();
        },
        onDone: () {
          _log("[CALL-DEBUG] WebSocket connection closed");
          _handleDisconnect();
        },
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _updateState(WsConnectionState.connected);
      _log("[CALL-DEBUG][RECEIVER] WS_CONNECTED");
      _log("[CALL-DEBUG] Successfully connected to Calling WebSocket for userId=$userId");
    } catch (e) {
      _log("[CALL-DEBUG] Failed to connect to Calling WebSocket: $e");
      _handleDisconnect();
    }
  }

  void _onDataReceived(dynamic data) {
    if (data == null) return;
    try {
      final String strData = data.toString();
      final Map<String, dynamic> jsonMap = jsonDecode(strData) as Map<String, dynamic>;

      // Create a sanitized copy of raw payload for diagnostic logging
      final sanitizedMap = Map<String, dynamic>.from(jsonMap);
      sanitizedMap.remove('token');
      sanitizedMap.remove('jwt');
      sanitizedMap.remove('fcmToken');
      sanitizedMap.remove('authorization');

      _log("[CALL-DEBUG] INCOMING_EVENT_PAYLOAD=${jsonEncode(sanitizedMap)}");

      final msg = SignalingMessageModel.fromJson(jsonMap);
      _messageController.add(msg);
    } catch (e, stack) {
      _log("[CALL-DEBUG] Error parsing incoming WebSocket message: $e");
      _log("[CALL-DEBUG] Parsing exception stack: $stack");
    }
  }

  void send(SignalingMessageModel message) {
    if (_connectionState != WsConnectionState.connected || _channel == null) {
      _log("[CALL-DEBUG] Cannot send message, WebSocket not connected. Attempting auto-reconnect...");
      connect().then((_) {
        if (_connectionState == WsConnectionState.connected && _channel != null) {
          _doSend(message);
        }
      });
      return;
    }
    _doSend(message);
  }

  void _doSend(SignalingMessageModel message) {
    try {
      final jsonStr = jsonEncode(message.toJson());
      _log("[CALL-DEBUG] Sending WS message type=${message.type}");
      _channel!.sink.add(jsonStr);
    } catch (e) {
      _log("[CALL-DEBUG] Error sending WebSocket message: $e");
    }
  }

  void _handleDisconnect() {
    _cleanupChannel();
    _updateState(WsConnectionState.disconnected);

    if (!_manualDisconnect && !_isDisposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    // Exponential backoff calculation: min(base * 2^attempts, maxDelay)
    final delayMs = (_baseDelayMs * (1 << _reconnectAttempts)).clamp(_baseDelayMs, _maxDelayMs);
    _reconnectAttempts++;

    _log("Scheduling WebSocket reconnect attempt #$_reconnectAttempts in ${delayMs}ms");

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_manualDisconnect && !_isDisposed) {
        connect();
      }
    });
  }

  void disconnect() {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _cleanupChannel();
    _updateState(WsConnectionState.disconnected);
    _log("Calling WebSocket disconnected manually");
  }

  void _cleanupChannel() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _updateState(WsConnectionState state) {
    _connectionState = state;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _cleanupChannel();
    _messageController.close();
    _connectionStateController.close();
  }

  void _log(String message) {
    developer.log("[CallingWebSocketService] $message");
  }
}
