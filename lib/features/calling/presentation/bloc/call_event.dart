import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/entities/signaling_message.dart';
import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCallingServiceEvent extends CallEvent {
  const InitializeCallingServiceEvent();
}

class InitiateOutgoingCallEvent extends CallEvent {
  final int targetUserId;
  final String targetName;
  final String targetAvatar;
  final String targetPhone;
  final CallType callType;

  const InitiateOutgoingCallEvent({
    required this.targetUserId,
    required this.targetName,
    this.targetAvatar = '',
    this.targetPhone = '',
    this.callType = CallType.voice,
  });

  @override
  List<Object?> get props => [
        targetUserId,
        targetName,
        targetAvatar,
        targetPhone,
        callType,
      ];
}

class IncomingCallReceivedEvent extends CallEvent {
  final SignalingMessage message;

  const IncomingCallReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class AcceptIncomingCallEvent extends CallEvent {
  const AcceptIncomingCallEvent();
}

class AcceptIncomingCallFromNativeEvent extends CallEvent {
  final String callId;
  final int callerId;
  final String callerName;
  final String callerAvatar;

  const AcceptIncomingCallFromNativeEvent({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar = '',
  });

  @override
  List<Object?> get props => [callId, callerId, callerName, callerAvatar];
}

class RejectIncomingCallEvent extends CallEvent {
  const RejectIncomingCallEvent();
}

class RejectIncomingCallFromNativeEvent extends CallEvent {
  final String callId;

  const RejectIncomingCallFromNativeEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

class CancelOutgoingCallEvent extends CallEvent {
  const CancelOutgoingCallEvent();
}

class HangupCallEvent extends CallEvent {
  const HangupCallEvent();
}

class ToggleMuteEvent extends CallEvent {
  const ToggleMuteEvent();
}

class ToggleSpeakerEvent extends CallEvent {
  const ToggleSpeakerEvent();
}

class SignalingMessageReceivedEvent extends CallEvent {
  final SignalingMessage message;

  const SignalingMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class CallTimerTickEvent extends CallEvent {
  const CallTimerTickEvent();
}

class CallFailedEvent extends CallEvent {
  final String message;

  const CallFailedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearCallStateEvent extends CallEvent {
  const ClearCallStateEvent();
}

class CheckActiveCallsEvent extends CallEvent {
  const CheckActiveCallsEvent();
}

