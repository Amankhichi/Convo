import 'dart:async';
import 'dart:convert';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/core/utils/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompService {
  final SecureStorage _secureStorage;
  StompClient? _stompClient;

  final StreamController<Map<String, dynamic>> _messageEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageEvents =>
      _messageEventController.stream;

  final Set<String> _activeSubscriptions = {};
  final Map<String, StompUnsubscribe> _subscriptionHandles = {};
  final Set<String> _desiredDestinations = {
    '/user/queue/messages',
    '/user/queue/notifications',
    '/topic/messages',
    '/topic/presence',
    '/topic/user/presence',
  };

  StompService(this._secureStorage);

  bool get isConnected => _stompClient?.connected ?? false;

  void connect() {
    if (_stompClient != null && _stompClient!.connected) return;

    final token = _secureStorage.getToken();
    final sockJsUrl =
        '${ApiConfig.baseUrl.replaceFirst('http', 'ws')}/ws/websocket';

    AppLogger.d("Connecting to STOMP WebSocket: $sockJsUrl");

    _stompClient = StompClient(
      config: StompConfig(
        url: sockJsUrl,
        onConnect: _onConnect,
        onWebSocketError: (error) => AppLogger.e("STOMP WS Error: $error"),
        onStompError: (frame) =>
            AppLogger.e("STOMP Frame Error: ${frame.body}"),
        onDisconnect: (frame) {
          AppLogger.d("STOMP Disconnected");
          _activeSubscriptions.clear();
          _subscriptionHandles.clear();
        },
        stompConnectHeaders: token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : {},
        webSocketConnectHeaders: token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : {},
        reconnectDelay: const Duration(seconds: 3),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    AppLogger.d("STOMP WebSocket Connected Successfully!");

    _activeSubscriptions.clear();
    _subscriptionHandles.clear();
    for (final destination in _desiredDestinations) {
      _subscribe(destination);
    }
  }

  void subscribeToChat(int chatId) {
    if (chatId <= 0) return;
    final topic1 = '/topic/chat/$chatId';
    final topic2 = '/topic/chats/$chatId';

    _desiredDestinations.add(topic1);
    _desiredDestinations.add(topic2);

    _subscribe(topic1);
    _subscribe(topic2);
  }

  void unsubscribeFromChat(int chatId) {
    if (chatId <= 0) return;
    final topic1 = '/topic/chat/$chatId';
    final topic2 = '/topic/chats/$chatId';

    _desiredDestinations.remove(topic1);
    _desiredDestinations.remove(topic2);

    _activeSubscriptions.remove(topic1);
    _activeSubscriptions.remove(topic2);

    try {
      _subscriptionHandles[topic1]?.call();
      _subscriptionHandles[topic2]?.call();
    } catch (_) {}

    _subscriptionHandles.remove(topic1);
    _subscriptionHandles.remove(topic2);
  }

  void _subscribe(String destination) {
    if (_stompClient == null || !_stompClient!.connected) return;
    if (_activeSubscriptions.contains(destination)) return;

    _activeSubscriptions.add(destination);
    final unsubscribeFn = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null && frame.body!.isNotEmpty) {
          try {
            AppLogger.d(
              "🔌 STOMP Event [$destination]: ${frame.body}",
            );
            final data = jsonDecode(frame.body!);
            if (data is Map<String, dynamic>) {
              _messageEventController.add(data);
            }
          } catch (e) {
            AppLogger.e("Error parsing STOMP frame body: $e");
          }
        }
      },
    );
    _subscriptionHandles[destination] = unsubscribeFn;
  }

  void sendStompMessage(String destination, Map<String, dynamic> body) {
    if (_stompClient != null && _stompClient!.connected) {
      _stompClient!.send(destination: destination, body: jsonEncode(body));
    }
  }

  void notifyMessageDelivered(int chatId, int messageId) {
    sendStompMessage('/app/chat.delivered', {
      'chatId': chatId,
      'messageId': messageId,
      'type': 'message:delivered',
    });
  }

  void notifyMessageSeen(int chatId, int messageId) {
    sendStompMessage('/app/chat.seen', {
      'chatId': chatId,
      'messageId': messageId,
      'type': 'message:seen',
    });
  }

  void sendTypingNotification(int chatId, bool isTyping) {
    sendStompMessage('/app/chat.typing', {
      'chatId': chatId,
      'isTyping': isTyping,
      'type': 'chat:typing',
    });
  }

  void disconnect() {
    _desiredDestinations.clear();
    _activeSubscriptions.clear();
    _subscriptionHandles.clear();
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
