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


class FakeCallingWebSocketService implements CallingWebSocketService {
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

class FakeWebRtcService implements WebRtcService {
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
    return RTCSessionDescription("mock_sdp_offer", "offer");
  }

  @override
  Future<RTCSessionDescription> handleOfferAndCreateAnswer(String offerSdp, {String roleTag = '[WEBRTC-DEBUG][B]'}) async {
    return RTCSessionDescription("mock_sdp_answer", "answer");
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


class FakeCallRepository implements CallRepository {
  ActiveCallResponseEntity? mockActiveCalls;

  @override
  List<CallLogEntity> getCallLogs() => [];

  @override
  Future<void> addCallLog(CallLogEntity log) async {}

  @override
  Future<List<IceServerEntity>> getIceServers() async => [];

  @override
  Future<List<CallLogEntity>> fetchCallHistory() async => [];

  @override
  Future<ActiveCallResponseEntity?> getActiveCalls() async => mockActiveCalls;
}

class FakeSecureStorage implements SecureStorage {
  @override
  int getUserId() => 101;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNativeCallKitService implements NativeCallKitService {
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

class FakeRingtoneService implements RingtoneService {
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
  late FakeCallingWebSocketService fakeWs;
  late FakeWebRtcService fakeWebRtc;
  late FakeCallRepository fakeRepo;
  late FakeSecureStorage fakeSecureStorage;
  late FakeNativeCallKitService fakeCallKit;
  late FakeRingtoneService fakeRingtone;

  setUp(() {
    fakeWs = FakeCallingWebSocketService();
    fakeWebRtc = FakeWebRtcService();
    fakeRepo = FakeCallRepository();
    fakeSecureStorage = FakeSecureStorage();
    fakeCallKit = FakeNativeCallKitService();
    fakeRingtone = FakeRingtoneService();

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

  group('Phase 6 CallBloc Unit Tests', () {
    test('Initiating outgoing call sets status to CallStatus.initiating (Calling...) NOT ringing', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Target User',
      ));

      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.initiating));
      expect(fakeWs.sentMessages.any((m) => m.type == 'initiate-call'), isTrue);
    });

    test('Status transitions from initiating (Calling) to ringing ONLY upon call-ringing event', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Target User',
      ));
      await pumpEventQueue();
      expect(bloc.state.status, equals(CallStatus.initiating));

      // Simulate backend sending 'call-ringing' signaling message
      fakeWs.emitMessage(const SignalingMessageModel(type: 'call-ringing'));
      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.ringing));
    });

    test('Incoming call event starts RingtoneService and NativeCallKitService', () async {
      bloc.add(const IncomingCallReceivedEvent(SignalingMessage(
        type: 'incoming-call',
        callId: 'call_test_123',
        from: '202',
        callerName: 'Alice',
      )));

      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.incoming));
      expect(fakeRingtone.isRinging, isTrue);
      expect(fakeCallKit.isShowing, isTrue);
    });

    test('Accepting incoming call stops ringtone and transitions to connecting', () async {
      bloc.add(const IncomingCallReceivedEvent(SignalingMessage(
        type: 'incoming-call',
        callId: 'call_test_123',
        from: '202',
        callerName: 'Alice',
      )));
      await pumpEventQueue();

      bloc.add(const AcceptIncomingCallEvent());
      await pumpEventQueue();

      expect(fakeRingtone.isRinging, isFalse);
      expect(bloc.state.status, equals(CallStatus.connecting));
      expect(fakeWs.sentMessages.any((m) => m.type == 'accept-call'), isTrue);
    });

    test('Rejecting incoming call stops ringtone and sets status to rejected', () async {
      bloc.add(const IncomingCallReceivedEvent(SignalingMessage(
        type: 'incoming-call',
        callId: 'call_test_123',
        from: '202',
        callerName: 'Alice',
      )));
      await pumpEventQueue();

      bloc.add(const RejectIncomingCallEvent());
      await pumpEventQueue();

      expect(fakeRingtone.isRinging, isFalse);
      expect(bloc.state.status, equals(CallStatus.rejected));
      expect(fakeWs.sentMessages.any((m) => m.type == 'reject-call'), isTrue);
    });

    test('Cancelling outgoing call stops ringtone and sends cancel-call', () async {
      bloc.add(const InitiateOutgoingCallEvent(
        targetUserId: 202,
        targetName: 'Target User',
      ));
      await pumpEventQueue();

      bloc.add(const CancelOutgoingCallEvent());
      await pumpEventQueue();

      expect(fakeRingtone.isRinging, isFalse);
      expect(bloc.state.status, equals(CallStatus.cancelled));
      expect(fakeWs.sentMessages.any((m) => m.type == 'cancel-call'), isTrue);
    });

    test('CheckActiveCallsEvent recovers active call for receiver when offline->online', () async {
      fakeRepo.mockActiveCalls = const ActiveCallResponseEntity(
        active: true,
        calls: [
          ActiveCallItemEntity(
            callId: 'recovered_room_1',
            callerUsername: 'Alice',
            callerId: 202,
            receiverUsername: 'Me',
            receiverId: 101,
            status: 'INITIATED',
          ),
        ],
      );

      bloc.add(const CheckActiveCallsEvent());
      await pumpEventQueue();

      expect(bloc.state.status, equals(CallStatus.incoming));
      expect(fakeRingtone.isRinging, isTrue);
    });
  });
}
