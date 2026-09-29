import 'package:convo/features/calling/domain/entities/call_session.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/domain/entities/call_user.dart';
import 'package:equatable/equatable.dart';

class CallState extends Equatable {
  final CallStatus status;
  final CallSession? session;
  final CallUser? remoteUser;
  final bool isMuted;
  final bool isSpeaker;
  final int durationSeconds;
  final String? errorMessage;

  const CallState({
    this.status = CallStatus.idle,
    this.session,
    this.remoteUser,
    this.isMuted = false,
    this.isSpeaker = false,
    this.durationSeconds = 0,
    this.errorMessage,
  });

  String get formattedTimer {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  CallState copyWith({
    CallStatus? status,
    CallSession? session,
    CallUser? remoteUser,
    bool? isMuted,
    bool? isSpeaker,
    int? durationSeconds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CallState(
      status: status ?? this.status,
      session: session ?? this.session,
      remoteUser: remoteUser ?? this.remoteUser,
      isMuted: isMuted ?? this.isMuted,
      isSpeaker: isSpeaker ?? this.isSpeaker,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        remoteUser,
        isMuted,
        isSpeaker,
        durationSeconds,
        errorMessage,
      ];
}
