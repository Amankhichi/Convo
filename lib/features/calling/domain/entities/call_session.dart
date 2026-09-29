import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/entities/call_user.dart';
import 'package:equatable/equatable.dart';

class CallSession extends Equatable {
  final String callId;
  final CallUser caller;
  final CallUser receiver;
  final CallType callType;
  final CallStatus status;
  final CallDirection direction;
  final DateTime? startTime;
  final DateTime? acceptTime;
  final DateTime? endTime;
  final int durationSeconds;

  const CallSession({
    required this.callId,
    required this.caller,
    required this.receiver,
    this.callType = CallType.voice,
    this.status = CallStatus.idle,
    required this.direction,
    this.startTime,
    this.acceptTime,
    this.endTime,
    this.durationSeconds = 0,
  });

  CallSession copyWith({
    String? callId,
    CallUser? caller,
    CallUser? receiver,
    CallType? callType,
    CallStatus? status,
    CallDirection? direction,
    DateTime? startTime,
    DateTime? acceptTime,
    DateTime? endTime,
    int? durationSeconds,
  }) {
    return CallSession(
      callId: callId ?? this.callId,
      caller: caller ?? this.caller,
      receiver: receiver ?? this.receiver,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      startTime: startTime ?? this.startTime,
      acceptTime: acceptTime ?? this.acceptTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
        callId,
        caller,
        receiver,
        callType,
        status,
        direction,
        startTime,
        acceptTime,
        endTime,
        durationSeconds,
      ];
}
