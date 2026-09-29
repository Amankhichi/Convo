import 'package:equatable/equatable.dart';

class SignalingMessage extends Equatable {
  final String type;
  final String? callId;
  final String? from;
  final String? to;
  final String? sdp;
  final Map<String, dynamic>? candidate;
  final String? reason;
  final String? callType;
  final String? callerName;
  final String? callerAvatar;

  const SignalingMessage({
    required this.type,
    this.callId,
    this.from,
    this.to,
    this.sdp,
    this.candidate,
    this.reason,
    this.callType,
    this.callerName,
    this.callerAvatar,
  });

  @override
  List<Object?> get props => [
        type,
        callId,
        from,
        to,
        sdp,
        candidate,
        reason,
        callType,
        callerName,
        callerAvatar,
      ];
}
