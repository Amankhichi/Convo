import 'dart:async';
import 'package:flutter/material.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:lottie/lottie.dart';

class VideoCallPage extends StatefulWidget {
  final UserModel user;

  const VideoCallPage({super.key, required this.user});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool isMuted = false;
  bool isCameraOff = false;
  bool isSpeakerOn = true;

  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// 🔴 Remote Video (Background Placeholder)
          Positioned.fill(
            child: isCameraOff
                ? Container(
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
                radius: 50,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Lottie.asset(
                    widget.user.lotti,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
                : Lottie.asset(
                    widget.user.lotti,
                    fit: BoxFit.cover,
                  ),
          ),

          /// 🔵 Top Info
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatTime(seconds),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// 🟢 Local Preview (Small Box)
          Positioned(
            top: 80,
            right: 20,
            child: Container(
              height: 150,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

          /// 🔘 Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                /// Mute
                _buildButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  color: isMuted ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => isMuted = !isMuted);
                  },
                ),

                /// Camera On/Off
                _buildButton(
                  icon: isCameraOff
                      ? Icons.videocam_off
                      : Icons.videocam,
                  color: isCameraOff ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => isCameraOff = !isCameraOff);
                  },
                ),

                /// Speaker
                _buildButton(
                  icon: isSpeakerOn
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white,
                  onTap: () {
                    setState(() => isSpeakerOn = !isSpeakerOn);
                  },
                ),

                /// End Call
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 65,
                    width: 65,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
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
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}