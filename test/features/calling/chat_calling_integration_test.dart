import 'dart:async';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/calling/data/datasources/calling_websocket_service.dart';
import 'package:convo/features/calling/data/models/signaling_message_model.dart';
import 'package:convo/features/calling/domain/entities/active_call_entity.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/entities/ice_server.dart';
import 'package:convo/features/calling/domain/entities/signaling_message.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:convo/features/calling/services/native_callkit_service.dart';
import 'package:convo/features/calling/services/ringtone_service.dart';
import 'package:convo/features/calling/services/webrtc_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class TestCallingWebSocketService implements CallingWebSocketService {
  final _messageController = StreamController<SignalingMessageModel>.broadcast();
  final _stateController = StreamController<WsConnectionState>.broadcast();
  final List<SignalingMessageModel> sentMessages = [];

  @override
  Stream<SignalingMessageModel> get messageStream => _messageController.stream;

  @override
  Stream<WsConnectionState> get connectionStateStream => _stateController.stream;

  @override
  WsConnectionState get connectionState => WsConnectionState.connected;

  @override
  Future<void> connect() async {
    _stateController.add(WsConnectionState.connected);
  }

  @override
  void send(SignalingMessageModel message) {
    sentMessages.add(message);
  }

  void emitMessage(SignalingMessageModel msg) {
    _messageController.add(msg);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestWebRtcService implements WebRtcService {
  @override
  OnIceCandidateCallback? onIceCandidate;
  @override
  OnConnectionStateCallback? onConnectionStateChanged;
  @override
  OnIceConnectionStateCallback? onIceConnectionStateChanged;
  @override
  void Function(MediaStream stream)? onRemoteStreamAdded;

  @override
  Future<void> initializePeerConnection(List<IceServerEntity> iceServers, {String roleTag = '[WEBRTC-DEBUG]'}) async {}

  @override
  Future<RTCSessionDescription> createOffer({String roleTag = '[WEBRTC-DEBUG][A]'}) async {
    return RTCSessionDescription("mock_offer_sdp", "offer");
  }

  @override
  Future<RTCSessionDescription> handleOfferAndCreateAnswer(String offerSdp, {String roleTag = '[WEBRTC-DEBUG][B]'}) async {
    return RTCSessionDescription("mock_answer_sdp", "answer");
  }

  @override
  Future<void> handleAnswer(String answerSdp, {String roleTag = '[WEBRTC-DEBUG][A]'}) async {}

  @override
  Future<void> addRemoteIceCandidate(Map<String, dynamic> candidateMap, {String roleTag = '[WEBRTC-DEBUG]'}) async {}

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestCallRepository implements CallRepository {
  List<CallLogEntity> mockHistory = [];
  ActiveCallResponseEntity? mockActiveCalls;

  @override
  List<CallLogEntity> getCallLogs() => mockHistory;

  @override
  Future<void> addCallLog(CallLogEntity log) async {
    mockHistory.add(log);
  }

  @override
  Future<List<IceServerEntity>> getIceServers() async => [];

  @override
  Future<List<CallLogEntity>> fetchCallHistory() async => mockHistory;

  @override
  Future<ActiveCallResponseEntity?> getActiveCalls() async => mockActiveCalls;
}

class TestSecureStorage implements SecureStorage {
  @override
  int getUserId() => 101;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestNativeCallKitService implements NativeCallKitService {
  bool isShowing = false;
  String? lastCallId;

  @override
  OnNativeCallAcceptCallback? onAcceptCall;

  @override
  OnNativeCallDeclineCallback? onDeclineCall;

  @override
  void initializeListeners() {}

  @override
  void dispose() {}

  @override
  Future<void> showIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
    required String callerAvatar,
    String callerPhone = '',
  }) async {
    isShowing = true;
    lastCallId = callId;
  }

  @override
  Future<void> dismissIncomingCall(String callId) async {
    isShowing = false;
  }

  @override
  Future<void> dismissAllCalls() async {
    isShowing = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestRingtoneService implements RingtoneService {
  @override
  bool isRinging = false;

  @override
  Future<void> startRinging() async {
    isRinging = true;
  }

  @override
  Future<void> startIncomingRingtone() async {
    await startRinging();
  }

  @override
  Future<void> startOutgoingRingtone() async {
    await startRinging();
  }

  @override
  Future<void> stopRinging() async {
    isRinging = false;
  }

  @override
  void dispose() {
    isRinging = false;
  }
}

void main() {
  late CallBloc bloc;
  late TestCallingWebSocketService fakeWs;
  late TestWebRtcService fakeWebRtc;
  late TestCallRepository fakeRepo;
  late TestSecureStorage fakeSecureStorage;
  late TestNativeCallKitService fakeCallKit;
  late TestRingtoneService fakeRingtone;

  setUp(() {
    fakeWs = TestCallingWebSocketService();
    fakeWebRtc = TestWebRtcService();
    fakeRepo = TestCallRepository();
    fakeSecureStorage = TestSecureStorage();
    fakeCallKit = TestNativeCallKitService();
    fakeRingtone = TestRingtoneService();

    bloc = CallBloc(
      wsService: fakeWs,
      webRtcService: fakeWebRtc,
      callRepository: fakeRepo,
      secureStorage: fakeSecureStorage,
      nativeCallKitService: fakeCallKit,
      ringtoneService: fakeRingtone,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Phase 7B Chat ↔ Calling Integration Tests', () {
    test('Initiating Voice Call from Chat selects correct target user and emits Calling... (initiating)', () async {
      const currentUserId = 101;
      const targetUserId = 202;

      expect(currentUserId, isNot(equals(targetUserId)));

      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: targetUserId,
        targetName: 'Bob',
        targetAvatar: 'https://example.com/bob.jpg',
        targetPhone: '+1234567890',
        callType: CallType.voice,
      ));

      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.initiating));
      expect(bloc.state.remoteUser?.id, equals(targetUserId));
      expect(bloc.state.remoteUser?.name, equals('Bob'));
      expect(fakeWs.sentMessages.any((m) => m.type == 'initiate-call' && m.to == '202'), isTrue);
    });

    test('Receiver reachable changes Calling... to Ringing...', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Bob',
      ));
      await pumpEventQueue();
      expect(bloc.state.status, equals(CallStatus.initiating));

      // Backend sends call-ringing event when receiver is online/reachable
      fakeWs.emitMessage(const SignalingMessageModel(type: 'call-ringing'));
      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.ringing));
    });

    test('Offline Receiver: Caller remains Calling... and Receiver shows no incoming UI', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Bob',
      ));
      await pumpEventQueue();

      // No call-ringing message is received because receiver is offline
      expect(bloc.state.status, equals(CallStatus.initiating));
      expect(fakeRingtone.isRinging, isFalse);
      expect(fakeCallKit.isShowing, isFalse);
    });

    test('Incoming Call displays UI, starts ringtone, and allows Accept', () async {
      bloc.add(const IncomingCallReceivedEvent(SignalingMessage(
        type: 'incoming-call',
        callId: 'call_chat_777',
        from: '202',
        callerName: 'Bob',
      )));
      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.incoming));
      expect(fakeRingtone.isRinging, isTrue);
      expect(fakeCallKit.isShowing, isTrue);

      bloc.add(const AcceptIncomingCallEvent());
      await pumpEventQueue();

      expect(fakeRingtone.isRinging, isFalse);
      expect(bloc.state.status, equals(CallStatus.connecting));
    });

    test('Incoming Call Reject dismisses native UI, stops ringtone, and updates call log', () async {
      bloc.add(const IncomingCallReceivedEvent(SignalingMessage(
        type: 'incoming-call',
        callId: 'call_chat_888',
        from: '202',
        callerName: 'Bob',
      )));
      await pumpEventQueue();

      bloc.add(const RejectIncomingCallEvent());
      await pumpEventQueue();

      expect(fakeRingtone.isRinging, isFalse);
      expect(bloc.state.status, equals(CallStatus.rejected));
      expect(fakeRepo.mockHistory.any((l) => l.direction == 'REJECTED'), isTrue);
    });

    test('Caller Cancel dismisses call and updates history', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Bob',
      ));
      await pumpEventQueue();

      bloc.add(const CancelOutgoingCallEvent());
      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.cancelled));
      expect(fakeRepo.mockHistory.any((l) => l.direction == 'OUTGOING'), isTrue);
    });

    test('Call History retrieval fetches stored logs', () async {
      fakeRepo.mockHistory = [
        const CallLogEntity(
          id: 'log_1',
          targetUserId: 202,
          targetUserName: 'Bob',
          targetUserImage: '',
          callType: 'VOICE',
          direction: 'INCOMING',
          timestamp: '2026-09-25T10:00:00Z',
          duration: '02:15',
        ),
      ];

      final logs = await fakeRepo.fetchCallHistory();
      expect(logs.length, equals(1));
      expect(logs.first.targetUserName, equals('Bob'));
      expect(logs.first.duration, equals('02:15'));
    });
  });
}
