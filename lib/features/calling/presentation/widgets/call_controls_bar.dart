import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:flutter/material.dart';

class CallControlsBar extends StatelessWidget {
  final CallStatus status;
  final bool isMuted;
  final bool isSpeaker;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onHangup;

  const CallControlsBar({
    super.key,
    required this.status,
    required this.isMuted,
    required this.isSpeaker,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
    required this.onHangup,
  });

  @override
  Widget build(BuildContext context) {
    if (status == CallStatus.incoming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reject Button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'reject_call_btn',
                backgroundColor: Colors.redAccent,
                onPressed: onReject,
                child: const Icon(Icons.call_end, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                "Decline",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          // Accept Button
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'accept_call_btn',
                backgroundColor: Colors.green,
                onPressed: onAccept,
                child: const Icon(Icons.call, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                "Accept",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      );
    }

    if (status == CallStatus.initiating || status == CallStatus.ringing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoundIconButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                label: isMuted ? "Unmute" : "Mute",
                isActive: isMuted,
                onPressed: onToggleMute,
              ),
              const SizedBox(width: 32),
              _buildRoundIconButton(
                icon: isSpeaker ? Icons.volume_up : Icons.volume_off,
                label: "Speaker",
                isActive: isSpeaker,
                onPressed: onToggleSpeaker,
              ),
            ],
          ),
          const SizedBox(height: 32),
          FloatingActionButton(
            heroTag: 'cancel_call_btn',
            backgroundColor: Colors.redAccent,
            onPressed: onCancel,
            child: const Icon(Icons.call_end, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          const Text(
            "Cancel",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      );
    }

    // Active or Connecting Call
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoundIconButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              label: isMuted ? "Unmute" : "Mute",
              isActive: isMuted,
              onPressed: onToggleMute,
            ),
            const SizedBox(width: 32),
            _buildRoundIconButton(
              icon: isSpeaker ? Icons.volume_up : Icons.volume_down,
              label: "Speaker",
              isActive: isSpeaker,
              onPressed: onToggleSpeaker,
            ),
          ],
        ),
        const SizedBox(height: 32),
        FloatingActionButton(
          heroTag: 'hangup_call_btn',
          backgroundColor: Colors.redAccent,
          onPressed: onHangup,
          child: const Icon(Icons.call_end, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        const Text(
          "End",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
