import 'dart:async';
import 'package:flutter/material.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:lottie/lottie.dart';

class VoiceCallPage extends StatefulWidget {
  final UserModel user;

  const VoiceCallPage({super.key, required this.user});

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool callConnected = false;

  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Simulate connecting call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => callConnected = true);
      startTimer();
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => seconds++);
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [

            /// Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    "Voice Call",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, color: Colors.white),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Avatar with Glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Lottie.asset(
                    widget.user.profile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Name
            Text(
              widget.user.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            /// Call Status
            Text(
              callConnected ? formatTime(seconds) : "Calling...",
              style: TextStyle(
                fontSize: 18,
                color: callConnected ? Colors.greenAccent : Colors.white70,
              ),
            ),

            const Spacer(),

            /// Bottom Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  /// Mute
                  _buildCallButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? Colors.red : Colors.white,
                    onTap: () {
                      setState(() => isMuted = !isMuted);
                    },
                  ),

                  /// End Call
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  /// Speaker
                  _buildCallButton(
                    icon: isSpeakerOn
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: isSpeakerOn ? Colors.green : Colors.white,
                    onTap: () {
                      setState(() => isSpeakerOn = !isSpeakerOn);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildCallButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    ),
  );
}
}