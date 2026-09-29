import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

typedef OnNativeCallAcceptCallback = void Function(
  String callId,
  String callerId,
  String callerName,
  String callerAvatar,
);

typedef OnNativeCallDeclineCallback = void Function(String callId);

class NativeCallKitService {
  StreamSubscription? _callkitSubscription;

  OnNativeCallAcceptCallback? onAcceptCall;
  OnNativeCallDeclineCallback? onDeclineCall;

  final Set<String> _activeCallIds = {};

  void initializeListeners() {
    _callkitSubscription?.cancel();
    _callkitSubscription = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      _log("Native CallKit Event: ${event.event} with body: ${event.body}");

      final Map<String, dynamic> body =
          event.body is Map ? Map<String, dynamic>.from(event.body as Map) : {};

      final callId = body['id']?.toString() ?? body['extra']?['callId']?.toString() ?? '';
      final extra = body['extra'] is Map ? Map<String, dynamic>.from(body['extra'] as Map) : {};
      final callerId = extra['callerId']?.toString() ?? '';
      final callerName = body['nameCaller']?.toString() ?? 'ConVo User';
      final callerAvatar = body['avatar']?.toString() ?? '';

      switch (event.event) {
        case Event.actionCallAccept:
          _log("Native UI Accept triggered for callId: $callId");
          _activeCallIds.add(callId);
          if (onAcceptCall != null) {
            onAcceptCall!(callId, callerId, callerName, callerAvatar);
          }
          break;

        case Event.actionCallDecline:
          _log("Native UI Decline triggered for callId: $callId");
          _activeCallIds.remove(callId);
          if (onDeclineCall != null) {
            onDeclineCall!(callId);
          }
          break;

        case Event.actionCallEnded:
        case Event.actionCallTimeout:
          _activeCallIds.remove(callId);
          break;

        default:
          break;
      }
    });
  }

  Future<void> showIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
    required String callerAvatar,
    String callerPhone = '',
  }) async {
    if (_activeCallIds.contains(callId)) {
      _log("Native call already displaying for callId: $callId. Skipping duplicate.");
      return;
    }

    _activeCallIds.add(callId);
    _log("Showing native incoming call screen for callId: $callId, caller: $callerName");

    final params = CallKitParams(
      id: callId,
      nameCaller: callerName.isNotEmpty ? callerName : 'ConVo User',
      appName: 'ConVo',
      avatar: callerAvatar,
      handle: callerPhone,
      type: 0, // 0 for audio call
      duration: 30000, // 30 second ringing timeout
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        'callId': callId,
        'callerId': callerId,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone',
        backgroundColor: '#0F172A',
        backgroundUrl: '',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
      ),
      ios: const IOSParams(
        iconName: 'CallKitIcon',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone',
      ),
    );

    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e) {
      _log("Error showing CallKit incoming screen: $e");
    }
  }

  Future<void> dismissIncomingCall(String callId) async {
    _activeCallIds.remove(callId);
    _log("Dismissing native incoming call screen for callId: $callId");
    try {
      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      _log("Error ending CallKit call: $e");
    }
  }

  Future<void> dismissAllCalls() async {
    _activeCallIds.clear();
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (_) {}
  }

  void dispose() {
    _callkitSubscription?.cancel();
    _callkitSubscription = null;
    onAcceptCall = null;
    onDeclineCall = null;
  }

  void _log(String message) {
    developer.log("[NativeCallKitService] $message");
  }
}
