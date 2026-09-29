import 'package:equatable/equatable.dart';

class ActiveCallItemEntity extends Equatable {
  final String callId;
  final String callerUsername;
  final int callerId;
  final String receiverUsername;
  final int receiverId;
  final String status;
  final String callType;

  const ActiveCallItemEntity({
    required this.callId,
    required this.callerUsername,
    this.callerId = 0,
    required this.receiverUsername,
    this.receiverId = 0,
    required this.status,
    this.callType = 'VOICE',
  });

  @override
  List<Object?> get props => [
        callId,
        callerUsername,
        callerId,
        receiverUsername,
        receiverId,
        status,
        callType,
      ];
}

class ActiveCallResponseEntity extends Equatable {
  final bool active;
  final List<ActiveCallItemEntity> calls;

  const ActiveCallResponseEntity({
    required this.active,
    required this.calls,
  });

  @override
  List<Object?> get props => [active, calls];
}
