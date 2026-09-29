import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:convo/features/calling/presentation/bloc/call_state.dart';
import 'package:convo/features/calling/presentation/widgets/call_avatar_widget.dart';
import 'package:convo/features/calling/presentation/widgets/call_controls_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallBloc, CallState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        if (state.status == CallStatus.idle && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final remoteUser = state.remoteUser;
        final name = remoteUser?.name ?? "ConVo User";
        final image = remoteUser?.profileImage ?? "";

        return PopScope(
          canPop: state.status.isTerminated || state.status == CallStatus.idle,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldEnd = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("End Call?"),
                content: const Text("Are you sure you want to end the active call?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("End Call", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (shouldEnd == true && context.mounted) {
              context.read<CallBloc>().add(const HangupCallEvent());
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  children: [
                    // Header / Status
                    Text(
                      _getStatusHeader(state.status),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    if (state.status == CallStatus.active)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          state.formattedTimer,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    else if (state.status == CallStatus.connecting)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),

                    const Spacer(),

                    // Center Avatar
                    CallAvatarWidget(
                      name: name,
                      imageUrl: image,
                      radius: 70,
                      isRinging: state.status == CallStatus.ringing ||
                          state.status == CallStatus.incoming,
                    ),

                    const Spacer(),

                    // Call Controls Bar
                    CallControlsBar(
                      status: state.status,
                      isMuted: state.isMuted,
                      isSpeaker: state.isSpeaker,
                      onToggleMute: () {
                        context.read<CallBloc>().add(const ToggleMuteEvent());
                      },
                      onToggleSpeaker: () {
                        context.read<CallBloc>().add(const ToggleSpeakerEvent());
                      },
                      onAccept: () {
                        context.read<CallBloc>().add(const AcceptIncomingCallEvent());
                      },
                      onReject: () {
                        context.read<CallBloc>().add(const RejectIncomingCallEvent());
                      },
                      onCancel: () {
                        context.read<CallBloc>().add(const CancelOutgoingCallEvent());
                      },
                      onHangup: () {
                        context.read<CallBloc>().add(const HangupCallEvent());
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStatusHeader(CallStatus status) {
    switch (status) {
      case CallStatus.initiating:
        return "Calling...";
      case CallStatus.ringing:
        return "Ringing...";
      case CallStatus.incoming:
        return "Incoming Voice Call";
      case CallStatus.connecting:
        return "Connecting...";
      case CallStatus.active:
        return "Voice Call";
      case CallStatus.ending:
        return "Ending Call...";
      case CallStatus.ended:
        return "Call Ended";
      case CallStatus.rejected:
        return "Call Rejected";
      case CallStatus.cancelled:
        return "Call Cancelled";
      case CallStatus.timedOut:
        return "No Answer";
      case CallStatus.failed:
        return "Call Failed";
      case CallStatus.idle:
        return "";
    }
  }
}
