import 'dart:async';
import 'dart:developer' as developer;
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/calling/data/datasources/calling_websocket_service.dart';
import 'package:convo/features/calling/data/models/signaling_message_model.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/entities/call_session.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/entities/call_user.dart';
import 'package:convo/features/calling/domain/entities/signaling_message.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:convo/features/calling/presentation/bloc/call_state.dart';
import 'package:convo/features/calling/services/native_callkit_service.dart';
import 'package:convo/features/calling/services/ringtone_service.dart';
import 'package:convo/features/calling/services/webrtc_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';


class CallBloc extends Bloc<CallEvent, CallState> {
  final CallingWebSocketService _wsService;
  final WebRtcService _webRtcService;
  final CallRepository _callRepository;
  final SecureStorage _secureStorage;
  final NativeCallKitService _nativeCallKitService;
  final RingtoneService _ringtoneService;

  StreamSubscription<SignalingMessageModel>? _wsSubscription;
  StreamSubscription<WsConnectionState>? _wsStateSubscription;
  Timer? _timer;
  Timer? _outgoingTimeoutTimer;

  CallBloc({
    required CallingWebSocketService wsService,
    required WebRtcService webRtcService,
    required CallRepository callRepository,
    required SecureStorage secureStorage,
    required NativeCallKitService nativeCallKitService,
    required RingtoneService ringtoneService,
  })  : _wsService = wsService,
        _webRtcService = webRtcService,
        _callRepository = callRepository,
        _secureStorage = secureStorage,
        _nativeCallKitService = nativeCallKitService,
        _ringtoneService = ringtoneService,
        super(const CallState()) {
    on<InitializeCallingServiceEvent>(_onInitializeCallingService);
    on<InitiateOutgoingCallEvent>(_onInitiateOutgoingCall);
    on<IncomingCallReceivedEvent>(_onIncomingCallReceived);
    on<AcceptIncomingCallEvent>(_onAcceptIncomingCall);
    on<AcceptIncomingCallFromNativeEvent>(_onAcceptIncomingCallFromNative);
    on<RejectIncomingCallEvent>(_onRejectIncomingCall);
    on<RejectIncomingCallFromNativeEvent>(_onRejectIncomingCallFromNative);
    on<CancelOutgoingCallEvent>(_onCancelOutgoingCall);
    on<HangupCallEvent>(_onHangupCall);
    on<ToggleMuteEvent>(_onToggleMute);
    on<ToggleSpeakerEvent>(_onToggleSpeaker);
    on<SignalingMessageReceivedEvent>(_onSignalingMessageReceived);
    on<CallTimerTickEvent>(_onCallTimerTick);
    on<CallFailedEvent>(_onCallFailed);
    on<ClearCallStateEvent>(_onClearCallState);
    on<CheckActiveCallsEvent>(_onCheckActiveCalls);

    _listenToWebSocketMessages();
    _listenToWebSocketConnectionState();
    _setupNativeCallkitListeners();
  }

  void _setupNativeCallkitListeners() {
    _nativeCallKitService.onAcceptCall = (callId, callerIdStr, callerName, callerAvatar) {
      final callerId = int.tryParse(callerIdStr) ?? 0;
      add(AcceptIncomingCallFromNativeEvent(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        callerAvatar: callerAvatar,
      ));
    };

    _nativeCallKitService.onDeclineCall = (callId) {
      add(RejectIncomingCallFromNativeEvent(callId));
    };

    _nativeCallKitService.initializeListeners();
  }

  void _listenToWebSocketMessages() {
    _wsSubscription?.cancel();
    _wsSubscription = _wsService.messageStream.listen((msg) {
      add(SignalingMessageReceivedEvent(msg));
    });
  }

  void _listenToWebSocketConnectionState() {
    _wsStateSubscription?.cancel();
    _wsStateSubscription = _wsService.connectionStateStream.listen((wsState) {
      if (wsState == WsConnectionState.connected) {
        add(const CheckActiveCallsEvent());
      }
    });
  }

  Future<void> _onInitializeCallingService(
    InitializeCallingServiceEvent event,
    Emitter<CallState> emit,
  ) async {
    await _wsService.connect();
    add(const CheckActiveCallsEvent());
  }

  Future<void> _onInitiateOutgoingCall(
    InitiateOutgoingCallEvent event,
    Emitter<CallState> emit,
  ) async {
    if (state.status.isInCall) {
      _log("Cannot initiate call: already in call state (${state.status})");
      return;
    }

    _log("[CALL-DEBUG][CALLER] INITIATE_CALL_STARTED");
    _log("[CALL-DEBUG][CALLER] receiverId=${event.targetUserId}");

    final currentUserId = _secureStorage.getUserId();
    final callId = "call_${DateTime.now().millisecondsSinceEpoch}_$currentUserId";
    _log("[CALL-DEBUG][CALLER] callId=$callId");

    final caller = CallUser(id: currentUserId, name: "Me");
    final receiver = CallUser(
      id: event.targetUserId,
      name: event.targetName,
      phone: event.targetPhone,
      profileImage: event.targetAvatar,
    );

    final session = CallSession(
      callId: callId,
      caller: caller,
      receiver: receiver,
      callType: event.callType,
      status: CallStatus.initiating,
      direction: CallDirection.outgoing,
      startTime: DateTime.now(),
    );

    _log("[CALL-DEBUG][CALLER] CALL_STATE old=${state.status} new=${CallStatus.initiating}");
    emit(state.copyWith(
      status: CallStatus.initiating,
      session: session,
      remoteUser: receiver,
      isMuted: false,
      isSpeaker: false,
      durationSeconds: 0,
      clearError: true,
    ));

    try {
      await _wsService.connect();

      _webRtcService.onIceCandidate = (candidate) {
        _log("[WEBRTC-DEBUG][A] ICE_CANDIDATE_CREATED candidate=${candidate.candidate}");
        _log("[WEBRTC-DEBUG][A] ICE_CANDIDATE_SENT");
        _wsService.send(SignalingMessageModel(
          type: 'ice-candidate',
          callId: callId,
          to: event.targetUserId.toString(),
          candidate: candidate.toMap(),
        ));
      };

      _webRtcService.onConnectionStateChanged = (connState) {
        _log("[WEBRTC-DEBUG][A] PEER_CONNECTION_STATE=${connState.name.toUpperCase()}");
        if (connState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          add(const CallFailedEvent("WebRTC Connection Failed"));
        }
      };

      _webRtcService.onIceConnectionStateChanged = (iceState) {
        _log("[WEBRTC-DEBUG][A] ICE_CONNECTION_STATE=${iceState.name.toUpperCase()}");
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (iceState == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          add(const CallFailedEvent("ICE Connection Failed"));
        }
      };

      final iceServers = await _callRepository.getIceServers();
      await _webRtcService.initializePeerConnection(iceServers, roleTag: '[WEBRTC-DEBUG][A]');

      _log("[CALL-DEBUG][CALLER] WS_SEND initiate-call");
      _wsService.send(SignalingMessageModel(
        type: 'initiate-call',
        callId: callId,
        to: event.targetUserId.toString(),
        callType: event.callType.toStr(),
      ));

      // Start 30-second outgoing call timeout
      _outgoingTimeoutTimer?.cancel();
      _outgoingTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (state.status == CallStatus.initiating || state.status == CallStatus.ringing) {
          _log("CALL_TIMEOUT");
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: 'call-timeout')));
        }
      });
    } catch (e) {
      _log("Error initiating outgoing call: $e");
      add(CallFailedEvent(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onIncomingCallReceived(
    IncomingCallReceivedEvent event,
    Emitter<CallState> emit,
  ) async {
    final callId = event.message.callId ?? '';

    if (state.status.isInCall) {
      if (state.session?.callId == callId) {
        _log("Already displaying incoming call for callId: $callId. Ignoring duplicate event.");
        return;
      }
      _wsService.send(SignalingMessageModel(
        type: 'reject-call',
        callId: callId,
        to: event.message.from,
        reason: 'BUSY',
      ));
      return;
    }

    _log("[CALL-DEBUG][RECEIVER] INCOMING_CALL_EVENT_RECEIVED");
    _log("[CALL-DEBUG][RECEIVER] callId=$callId");
    _log("[CALL-DEBUG][RECEIVER] callerId=${event.message.from}");
    _log("[CALL-DEBUG][RECEIVER] callerName=${event.message.callerName}");

    final callerId = int.tryParse(event.message.from ?? '0') ?? 0;
    final caller = CallUser(
      id: callerId,
      name: event.message.callerName ?? 'Unknown Caller',
      profileImage: event.message.callerAvatar ?? '',
    );

    final currentUserId = _secureStorage.getUserId();
    final receiver = CallUser(id: currentUserId, name: 'Me');

    final session = CallSession(
      callId: callId,
      caller: caller,
      receiver: receiver,
      callType: CallTypeX.fromStr(event.message.callType),
      status: CallStatus.incoming,
      direction: CallDirection.incoming,
      startTime: DateTime.now(),
    );

    _log("[CALL-DEBUG][RECEIVER] CALL_STATE old=${state.status} new=${CallStatus.incoming}");
    _log("[CALL-DEBUG][RECEIVER] INCOMING_CALL_STATE_EMITTED");
    emit(state.copyWith(
      status: CallStatus.incoming,
      session: session,
      remoteUser: caller,
      isMuted: false,
      isSpeaker: false,
      durationSeconds: 0,
      clearError: true,
    ));

    // Start incoming ringing sound & vibration
    _log("[CALL-DEBUG][RECEIVER] RINGTONE_START");
    await _ringtoneService.startIncomingRingtone();

    // Display native CallKit incoming banner
    await _nativeCallKitService.showIncomingCall(
      callId: session.callId,
      callerId: callerId.toString(),
      callerName: caller.name,
      callerAvatar: caller.profileImage,
    );
  }

  Future<void> _onAcceptIncomingCall(
    AcceptIncomingCallEvent event,
    Emitter<CallState> emit,
  ) async {
    if (state.session == null || state.status != CallStatus.incoming) return;

    _log("CALL_ACCEPTED");
    await _ringtoneService.stopRinging();

    final callId = state.session!.callId;
    await _nativeCallKitService.dismissIncomingCall(callId);
    emit(state.copyWith(status: CallStatus.connecting));

    final callerId = state.session!.caller.id.toString();

    try {
      try {
        final micStatus = await Permission.microphone.status;
        if (micStatus.isPermanentlyDenied) {
          add(const CallFailedEvent("Microphone permission denied"));
          return;
        }
        if (!micStatus.isGranted) {
          final requested = await Permission.microphone.request();
          if (requested.isPermanentlyDenied) {
            add(const CallFailedEvent("Microphone permission denied"));
            return;
          }
        }
      } catch (_) {}

      _webRtcService.onIceCandidate = (candidate) {
        _log("[WEBRTC-DEBUG][B] ICE_CANDIDATE_CREATED candidate=${candidate.candidate}");
        _log("[WEBRTC-DEBUG][B] ICE_CANDIDATE_SENT");
        _wsService.send(SignalingMessageModel(
          type: 'ice-candidate',
          callId: callId,
          to: callerId,
          candidate: candidate.toMap(),
        ));
      };

      _webRtcService.onConnectionStateChanged = (connState) {
        _log("[WEBRTC-DEBUG][B] PEER_CONNECTION_STATE=${connState.name.toUpperCase()}");
        if (connState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          add(const CallFailedEvent("WebRTC Connection Failed"));
        }
      };

      _webRtcService.onIceConnectionStateChanged = (iceState) {
        _log("[WEBRTC-DEBUG][B] ICE_CONNECTION_STATE=${iceState.name.toUpperCase()}");
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (iceState == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          add(const CallFailedEvent("ICE Connection Failed"));
        }
      };

      final iceServers = await _callRepository.getIceServers();
      await _webRtcService.initializePeerConnection(iceServers, roleTag: '[WEBRTC-DEBUG][B]');

      _wsService.send(SignalingMessageModel(
        type: 'accept-call',
        callId: callId,
        to: callerId,
      ));
    } catch (e) {
      _log("Error accepting call: $e");
      add(CallFailedEvent(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onAcceptIncomingCallFromNative(
    AcceptIncomingCallFromNativeEvent event,
    Emitter<CallState> emit,
  ) async {
    _log("CALL_ACCEPTED (from native CallKit): ${event.callId}");
    await _ringtoneService.stopRinging();

    final currentUserId = _secureStorage.getUserId();
    final caller = CallUser(
      id: event.callerId,
      name: event.callerName,
      profileImage: event.callerAvatar,
    );

    final session = CallSession(
      callId: event.callId,
      caller: caller,
      receiver: CallUser(id: currentUserId, name: 'Me'),
      callType: CallType.voice,
      status: CallStatus.connecting,
      direction: CallDirection.incoming,
      startTime: DateTime.now(),
    );

    emit(state.copyWith(
      status: CallStatus.connecting,
      session: session,
      remoteUser: caller,
      isMuted: false,
      isSpeaker: false,
      durationSeconds: 0,
      clearError: true,
    ));

    try {
      try {
        final micStatus = await Permission.microphone.status;
        if (micStatus.isPermanentlyDenied) {
          add(const CallFailedEvent("Microphone permission denied"));
          return;
        }
        if (!micStatus.isGranted) {
          final requested = await Permission.microphone.request();
          if (requested.isPermanentlyDenied) {
            add(const CallFailedEvent("Microphone permission denied"));
            return;
          }
        }
      } catch (_) {}

      await _wsService.connect();

      _webRtcService.onIceCandidate = (candidate) {
        _log("[WEBRTC-DEBUG][B] ICE_CANDIDATE_CREATED candidate=${candidate.candidate}");
        _log("[WEBRTC-DEBUG][B] ICE_CANDIDATE_SENT");
        _wsService.send(SignalingMessageModel(
          type: 'ice-candidate',
          callId: event.callId,
          to: event.callerId.toString(),
          candidate: candidate.toMap(),
        ));
      };

      _webRtcService.onConnectionStateChanged = (connState) {
        _log("[WEBRTC-DEBUG][B] PEER_CONNECTION_STATE=${connState.name.toUpperCase()}");
        if (connState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          add(const CallFailedEvent("WebRTC Connection Failed"));
        }
      };

      _webRtcService.onIceConnectionStateChanged = (iceState) {
        _log("[WEBRTC-DEBUG][B] ICE_CONNECTION_STATE=${iceState.name.toUpperCase()}");
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          add(const SignalingMessageReceivedEvent(SignalingMessage(type: '_webrtc_connected')));
        } else if (iceState == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          add(const CallFailedEvent("ICE Connection Failed"));
        }
      };

      final iceServers = await _callRepository.getIceServers();
      await _webRtcService.initializePeerConnection(iceServers, roleTag: '[WEBRTC-DEBUG][B]');

      _wsService.send(SignalingMessageModel(
        type: 'accept-call',
        callId: event.callId,
        to: event.callerId.toString(),
      ));
    } catch (e) {
      _log("Error accepting native call: $e");
      add(CallFailedEvent(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onRejectIncomingCall(
    RejectIncomingCallEvent event,
    Emitter<CallState> emit,
  ) async {
    _log("CALL_REJECTED");
    await _ringtoneService.stopRinging();

    final session = state.session;
    if (session != null) {
      _wsService.send(SignalingMessageModel(
        type: 'reject-call',
        callId: session.callId,
        to: session.caller.id.toString(),
      ));
      await _nativeCallKitService.dismissIncomingCall(session.callId);
      await _recordCallLog(session, CallStatus.rejected);
    }

    await _cleanupCallResources();
    emit(state.copyWith(status: CallStatus.rejected));
    _scheduleClearState();
  }

  Future<void> _onRejectIncomingCallFromNative(
    RejectIncomingCallFromNativeEvent event,
    Emitter<CallState> emit,
  ) async {
    _log("CALL_REJECTED (native): ${event.callId}");
    await _ringtoneService.stopRinging();

    _wsService.send(SignalingMessageModel(
      type: 'reject-call',
      callId: event.callId,
    ));

    if (state.session != null) {
      await _recordCallLog(state.session!, CallStatus.rejected);
    }

    await _cleanupCallResources();
    emit(state.copyWith(status: CallStatus.rejected));
    _scheduleClearState();
  }

  Future<void> _onCancelOutgoingCall(
    CancelOutgoingCallEvent event,
    Emitter<CallState> emit,
  ) async {
    _log("CALL_CANCELLED");
    await _ringtoneService.stopRinging();

    final session = state.session;
    if (session != null) {
      _wsService.send(SignalingMessageModel(
        type: 'cancel-call',
        callId: session.callId,
        to: session.receiver.id.toString(),
      ));
      await _nativeCallKitService.dismissIncomingCall(session.callId);
      await _recordCallLog(session, CallStatus.cancelled);
    }

    await _cleanupCallResources();
    emit(state.copyWith(status: CallStatus.cancelled));
    _scheduleClearState();
  }

  Future<void> _onHangupCall(
    HangupCallEvent event,
    Emitter<CallState> emit,
  ) async {
    await _ringtoneService.stopRinging();

    final session = state.session;
    if (session != null) {
      final targetId = session.direction == CallDirection.outgoing
          ? session.receiver.id.toString()
          : session.caller.id.toString();

      _wsService.send(SignalingMessageModel(
        type: 'hangup',
        callId: session.callId,
        to: targetId,
      ));

      await _nativeCallKitService.dismissIncomingCall(session.callId);
      await _recordCallLog(session, CallStatus.ended, durationSeconds: state.durationSeconds);
    }

    await _cleanupCallResources();
    emit(state.copyWith(status: CallStatus.ended));
    _scheduleClearState();
  }

  Future<void> _onSignalingMessageReceived(
    SignalingMessageReceivedEvent event,
    Emitter<CallState> emit,
  ) async {
    final msg = event.message;
    final isCaller = state.session?.direction == CallDirection.outgoing;
    final roleTag = isCaller ? "[CALL-DEBUG][CALLER]" : "[CALL-DEBUG][RECEIVER]";
    _log("$roleTag CALL_EVENT_RECEIVED type=${msg.type}");

    switch (msg.type) {
      case 'incoming-call':
      case 'incoming_call':
        add(IncomingCallReceivedEvent(msg));
        break;

      case 'call-ringing':
      case 'call_ringing':
      case 'ringing':
      case 'call-initiated':
      case 'call_initiated':
      case 'initiated':
        _log("[CALL-DEBUG][CALLER] RECEIVER_REACHABLE");
        _log("[CALL-DEBUG][CALLER] CALL_RINGING");
        if (state.status == CallStatus.initiating) {
          _log("[CALL-DEBUG][CALLER] CALL_STATE old=${state.status} new=${CallStatus.ringing}");
          final updatedSession = (state.session != null && msg.callId != null && msg.callId!.isNotEmpty)
              ? state.session!.copyWith(callId: msg.callId)
              : state.session;
          emit(state.copyWith(status: CallStatus.ringing, session: updatedSession));
          _log("[CALL-DEBUG][CALLER] RINGING_SOUND_START");
          await _ringtoneService.startOutgoingRingtone();
        }
        break;

      case 'call-accepted':
      case 'call_accepted':
      case 'accepted':
        _log("[CALL-DEBUG][CALLER] CALL_ACCEPTED");
        _log("[CALL-DEBUG][CALLER] RINGING_SOUND_STOP");
        await _ringtoneService.stopRinging();
        if (state.status == CallStatus.ringing || state.status == CallStatus.initiating) {
          _log("[CALL-DEBUG][CALLER] CALL_STATE old=${state.status} new=${CallStatus.connecting}");
          final updatedSession = (state.session != null && msg.callId != null && msg.callId!.isNotEmpty)
              ? state.session!.copyWith(callId: msg.callId)
              : state.session;
          emit(state.copyWith(status: CallStatus.connecting, session: updatedSession));
          try {
            _log("[WEBRTC-DEBUG][A] Creating SDP Offer...");
            final offer = await _webRtcService.createOffer(roleTag: '[WEBRTC-DEBUG][A]');
            final effectiveCallId = msg.callId ?? updatedSession?.callId;
            final targetId = updatedSession?.receiver.id.toString();
            _log("[WEBRTC-DEBUG][A] SDP_OFFER_SENT");
            _wsService.send(SignalingMessageModel(
              type: 'sdp-offer',
              callId: effectiveCallId,
              to: targetId,
              sdp: offer.sdp,
            ));
          } catch (e) {
            _log("Error creating SDP offer: $e");
            add(CallFailedEvent("Failed to create SDP offer"));
          }
        }
        break;

      case 'sdp-offer':
        if (msg.sdp != null) {
          _log("[WEBRTC-DEBUG][B] SDP_OFFER_RECEIVED");
          try {
            final answer = await _webRtcService.handleOfferAndCreateAnswer(msg.sdp!, roleTag: '[WEBRTC-DEBUG][B]');
            final targetId = state.session?.caller.id.toString();
            _log("[WEBRTC-DEBUG][B] SDP_ANSWER_SENT");
            _wsService.send(SignalingMessageModel(
              type: 'sdp-answer',
              callId: state.session?.callId,
              to: targetId,
              sdp: answer.sdp,
            ));
          } catch (e) {
            _log("Error processing SDP offer: $e");
            add(CallFailedEvent("Failed to process SDP offer"));
          }
        }
        break;

      case 'sdp-answer':
        if (msg.sdp != null) {
          _log("[WEBRTC-DEBUG][A] SDP_ANSWER_RECEIVED");
          try {
            await _webRtcService.handleAnswer(msg.sdp!, roleTag: '[WEBRTC-DEBUG][A]');
          } catch (e) {
            _log("Error processing SDP answer: $e");
          }
        }
        break;

      case 'ice-candidate':
        if (msg.candidate != null) {
          final roleTag = isCaller ? "[WEBRTC-DEBUG][A]" : "[WEBRTC-DEBUG][B]";
          _log("$roleTag ICE_CANDIDATE_RECEIVED");
          await _webRtcService.addRemoteIceCandidate(msg.candidate!, roleTag: roleTag);
        }
        break;

      case '_webrtc_connected':
        if (state.status != CallStatus.active) {
          _log("[CALL-DEBUG] CALL_CONNECTED");
          _log("[CALL-DEBUG] RINGING_SOUND_STOP");
          await _ringtoneService.stopRinging();
          _log("[CALL-DEBUG] CALL_STATE old=${state.status} new=${CallStatus.active}");
          emit(state.copyWith(status: CallStatus.active));
          _startCallTimer();
        }
        break;

      case 'call-rejected':
      case 'call_rejected':
      case 'rejected':
        _log("[CALL-DEBUG] CALL_REJECTED");
        _log("[CALL-DEBUG] RINGING_SOUND_STOP");
        await _ringtoneService.stopRinging();
        if (state.session != null) {
          await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
          await _recordCallLog(state.session!, CallStatus.rejected);
        }
        await _cleanupCallResources();
        _log("[CALL-DEBUG] CALL_STATE old=${state.status} new=${CallStatus.rejected}");
        emit(state.copyWith(
          status: CallStatus.rejected,
          errorMessage: "Call rejected by remote user",
        ));
        _scheduleClearState();
        break;

      case 'call-cancelled':
      case 'call_cancelled':
      case 'cancelled':
        _log("[CALL-DEBUG] CALL_CANCELLED");
        _log("[CALL-DEBUG] RINGING_SOUND_STOP");
        await _ringtoneService.stopRinging();
        if (state.session != null) {
          await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
          await _recordCallLog(state.session!, CallStatus.cancelled);
        }
        await _cleanupCallResources();
        _log("[CALL-DEBUG] CALL_STATE old=${state.status} new=${CallStatus.cancelled}");
        emit(state.copyWith(
          status: CallStatus.cancelled,
          errorMessage: "Call cancelled by caller",
        ));
        _scheduleClearState();
        break;

      case 'call-timeout':
      case 'call_timeout':
      case 'timeout':
        _log("[CALL-DEBUG] CALL_TIMEOUT");
        _log("[CALL-DEBUG] RINGING_SOUND_STOP");
        await _ringtoneService.stopRinging();
        if (state.session != null) {
          await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
          await _recordCallLog(state.session!, CallStatus.timedOut);
        }
        await _cleanupCallResources();
        _log("[CALL-DEBUG] CALL_STATE old=${state.status} new=${CallStatus.timedOut}");
        emit(state.copyWith(
          status: CallStatus.timedOut,
          errorMessage: "Call timed out",
        ));
        _scheduleClearState();
        break;

      case 'call-ended':
      case 'call_ended':
      case 'ended':
      case 'hangup':
        _log("[CALL-DEBUG] CALL_ENDED");
        _log("[CALL-DEBUG] RINGING_SOUND_STOP");
        await _ringtoneService.stopRinging();
        if (state.session != null) {
          await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
          await _recordCallLog(state.session!, CallStatus.ended, durationSeconds: state.durationSeconds);
        }
        await _cleanupCallResources();
        _log("[CALL-DEBUG] CALL_STATE old=${state.status} new=${CallStatus.ended}");
        emit(state.copyWith(status: CallStatus.ended));
        _scheduleClearState();
        break;
    }
  }

  Future<void> _onCheckActiveCalls(
    CheckActiveCallsEvent event,
    Emitter<CallState> emit,
  ) async {
    try {
      final activeResponse = await _callRepository.getActiveCalls();
      final currentUserId = _secureStorage.getUserId();

      if (activeResponse != null && activeResponse.active && activeResponse.calls.isNotEmpty) {
        final matchingCall = activeResponse.calls.firstWhere(
          (c) =>
              c.status.toUpperCase() == 'INITIATED' ||
              c.status.toUpperCase() == 'RINGING' ||
              c.status.toUpperCase() == 'ACTIVE',
          orElse: () => activeResponse.calls.first,
        );

        final callStatusStr = matchingCall.status.toUpperCase();

        if (callStatusStr == 'INITIATED' || callStatusStr == 'RINGING') {
          // If current user is receiver and state is idle, recover incoming call!
          if ((matchingCall.receiverId == currentUserId || matchingCall.receiverUsername.isNotEmpty) &&
              state.status == CallStatus.idle) {
            _log("Recovering active incoming call from backend: callId=${matchingCall.callId}");
            add(IncomingCallReceivedEvent(SignalingMessage(
              type: 'incoming-call',
              callId: matchingCall.callId,
              from: matchingCall.callerId > 0
                  ? matchingCall.callerId.toString()
                  : matchingCall.callerUsername,
              callerName: matchingCall.callerUsername,
              callType: matchingCall.callType,
            )));
          }
        }
      } else {
        // If active call response is false/empty and we are in a call, clear stale call
        if (state.status.isInCall && state.status == CallStatus.incoming) {
          _log("Active call recovery: Backend returned no active calls. Dismissing stale call.");
          await _ringtoneService.stopRinging();
          if (state.session != null) {
            await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
          }
          await _cleanupCallResources();
          emit(const CallState(status: CallStatus.idle));
        }
      }
    } catch (e) {
      _log("Error during active call recovery check: $e");
    }
  }

  void _onToggleMute(ToggleMuteEvent event, Emitter<CallState> emit) {
    final newMute = !state.isMuted;
    _webRtcService.setMute(newMute);
    emit(state.copyWith(isMuted: newMute));
  }

  Future<void> _onToggleSpeaker(ToggleSpeakerEvent event, Emitter<CallState> emit) async {
    final newSpeaker = !state.isSpeaker;
    await _webRtcService.setSpeakerphoneOn(newSpeaker);
    emit(state.copyWith(isSpeaker: newSpeaker));
  }

  void _onCallTimerTick(CallTimerTickEvent event, Emitter<CallState> emit) {
    if (state.status == CallStatus.active) {
      emit(state.copyWith(durationSeconds: state.durationSeconds + 1));
    }
  }

  Future<void> _onCallFailed(CallFailedEvent event, Emitter<CallState> emit) async {
    await _ringtoneService.stopRinging();
    if (state.session != null) {
      await _nativeCallKitService.dismissIncomingCall(state.session!.callId);
      await _recordCallLog(state.session!, CallStatus.failed);
    }
    await _cleanupCallResources();
    emit(state.copyWith(
      status: CallStatus.failed,
      errorMessage: event.message,
    ));
    _scheduleClearState();
  }

  void _onClearCallState(ClearCallStateEvent event, Emitter<CallState> emit) {
    emit(const CallState(status: CallStatus.idle));
  }

  void _startCallTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const CallTimerTickEvent());
    });
  }

  Future<void> _cleanupCallResources() async {
    _timer?.cancel();
    _timer = null;
    _outgoingTimeoutTimer?.cancel();
    _outgoingTimeoutTimer = null;
    await _ringtoneService.stopRinging();
    await _webRtcService.dispose();
    await _nativeCallKitService.dismissAllCalls();
  }

  Future<void> _recordCallLog(
    CallSession session,
    CallStatus status, {
    int durationSeconds = 0,
  }) async {
    final remote = session.direction == CallDirection.outgoing ? session.receiver : session.caller;

    String dirStr = 'OUTGOING';
    if (session.direction == CallDirection.incoming) {
      dirStr = status == CallStatus.rejected ? 'REJECTED' : 'INCOMING';
    } else {
      dirStr = status == CallStatus.rejected ? 'REJECTED' : 'OUTGOING';
    }

    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    final durationStr = durationSeconds > 0 ? "$minutes:$seconds" : "";

    final log = CallLogEntity(
      id: session.callId,
      targetUserId: remote.id,
      targetUserName: remote.name,
      targetUserImage: remote.profileImage,
      callType: session.callType.toStr(),
      direction: dirStr,
      timestamp: DateTime.now().toIso8601String(),
      duration: durationStr,
    );

    await _callRepository.addCallLog(log);
  }

  void _scheduleClearState() {
    Timer(const Duration(seconds: 2), () {
      if (!isClosed) {
        add(const ClearCallStateEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _outgoingTimeoutTimer?.cancel();
    _wsSubscription?.cancel();
    _wsStateSubscription?.cancel();
    _ringtoneService.dispose();
    _webRtcService.dispose();
    _nativeCallKitService.dispose();
    return super.close();
  }

  void _log(String message) {
    developer.log("[CallBloc] $message");
  }
}
