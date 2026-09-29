import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:convo/features/calling/domain/repositories/device_token_repository.dart';
import 'package:convo/features/calling/services/native_callkit_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log("[PushNotificationService] Background message received: ${message.messageId}");
  final data = message.data;
  final type = data['type']?.toString();

  if (type == 'incoming_call' || type == 'VOICE_CALL' || type == 'call') {
    final callId = data['callId']?.toString() ?? '';
    final callerId = data['callerId']?.toString() ?? '';
    final callerName = data['callerName']?.toString() ?? 'ConVo User';
    final callerAvatar = data['callerAvatar']?.toString() ?? '';

    if (callId.isNotEmpty) {
      final callkit = NativeCallKitService();
      await callkit.showIncomingCall(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      );
    }
  }
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DeviceTokenRepository _deviceTokenRepository;
  final NativeCallKitService _nativeCallKitService;

  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _onMessageSubscription;

  final Set<String> _processedCallIds = {};

  PushNotificationService(
    this._deviceTokenRepository,
    this._nativeCallKitService,
  );

  Future<void> initialize() async {
    _log("Initializing PushNotificationService...");

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _log("Push notification permission status: ${settings.authorizationStatus}");

    // Retrieve FCM Token and register with backend
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        final platform = Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'OTHER');
        await _deviceTokenRepository.registerDeviceToken(token, platform);
      }
    } catch (e) {
      _log("Error retrieving or registering FCM token: $e");
    }

    // Token refresh listener
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _log("FCM Token refreshed: $newToken");
      final platform = Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'OTHER');
      await _deviceTokenRepository.registerDeviceToken(newToken, platform);
    });

    // Foreground message listener
    _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handlePushMessage(message);
    });

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void _handlePushMessage(RemoteMessage message) {
    final data = message.data;
    _log("Foreground push notification payload received: $data");

    final type = data['type']?.toString();
    if (type == 'incoming_call' || type == 'VOICE_CALL' || type == 'call') {
      final callId = data['callId']?.toString() ?? '';
      final callerId = data['callerId']?.toString() ?? '';
      final callerName = data['callerName']?.toString() ?? 'ConVo User';
      final callerAvatar = data['callerAvatar']?.toString() ?? '';

      if (callId.isEmpty) return;

      if (_processedCallIds.contains(callId)) {
        _log("CallId $callId already processed via WebSocket/Push. Skipping duplicate UI.");
        return;
      }

      _processedCallIds.add(callId);
      _nativeCallKitService.showIncomingCall(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      );
    }
  }

  void markCallProcessed(String callId) {
    _processedCallIds.add(callId);
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _onMessageSubscription?.cancel();
  }

  void _log(String message) {
    developer.log("[PushNotificationService] $message");
  }
}
