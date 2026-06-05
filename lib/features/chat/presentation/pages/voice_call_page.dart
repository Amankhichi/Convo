import 'dart:async';
import 'package:convo/const.dart/api_config.dart';
import 'package:flutter/material.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart'; // Handles background cellular calls
import 'package:audio_session/audio_session.dart'; // Added for hardware speaker routing
import 'package:permission_handler/permission_handler.dart'; // Add this at the top

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
  bool isUsingCellularFallback = false; 

  int seconds = 0;
  Timer? timer;
  
  // Keep track of any pending internet call connection delays
  Timer? _internetHandshakeTimeout;

  @override
  void initState() {
    super.initState();
    _startSmartCallRouting();
  }

  // --- SMART ROUTING MANAGER ---
  Future<void> _startSmartCallRouting() async {
    // 1. Check if the 2nd user is online for an internet call
    bool isInternetCallPossible = await _checkInternetAvailability();

    if (isInternetCallPossible) {
      // Setup internet call connection sequence safely using a trackable timer reference
      _internetHandshakeTimeout = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => callConnected = true);
          startTimer();
        }
      });
    } else {
      // --- AUTOMATICALLY CUT INTERNET CALL STREAMS HERE ---
      _terminateInternetCallChannels();

      // 2. Request Android OS to prioritize this app as the default dialer handler
      if (await Permission.phone.request().isGranted) {
        // var status = await Permission.manageExternalStorage.status; // fallback check pointer
      }

      if (mounted) {
        setState(() {
          isUsingCellularFallback = true;
          callConnected = true; 
        });
        startTimer();
      }
      
      final String targetPhoneNumber = widget.user.phone; 
      if (targetPhoneNumber.isNotEmpty) {
        // Execute direct background link request
        await FlutterPhoneDirectCaller.callNumber(targetPhoneNumber);
      }
    }
  }

  // Cuts off and disconnects all active internet call processes cleanly
  void _terminateInternetCallChannels() {
    // 1. Cancel the internet connection timeout handler immediately
    _internetHandshakeTimeout?.cancel();
    _internetHandshakeTimeout = null;

    // 2. Stop the local calling UI timer to reset state values safely
    timer?.cancel();
    timer = null;
    
    if (mounted) {
      setState(() {
        seconds = 0;
        callConnected = false;
      });
    }

    // TODO: If you integrate Agora or WebRTC later, add your signaling termination commands here:
    // e.g., _engine.leaveChannel(); or _rtcConnection.close();
    debugPrint("Internet call fully disconnected. Ready to switch to SIM card line.");
  }

  // Simulates network handshake to see if recipient can accept internet call
  Future<bool> _checkInternetAvailability() async {
    await Future.delayed(const Duration(seconds: 2)); // Wait for target user ping response
    
    bool isRecipientOnline = false; // Force false to test the cellular fallback routine
    return isRecipientOnline;
  }

  void startTimer() {
    timer?.cancel(); // Safety measure to avoid creating multiple duplicate timer loops
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => seconds++);
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  // --- NATIVE HARDWARE SPEAKER TOGGLE ---
  void toggleSpeaker() async {
    final session = await AudioSession.instance;
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    
    if (isSpeakerOn) {
      // Forces the device audio routing matrix onto the loudspeaker hardware
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
      ));
    } else {
      // Returns it back to the normal ear receiver speaker piece
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      ));
    }
  }

  @override
  void dispose() {
    _internetHandshakeTimeout?.cancel();
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
                    Text(
                      isUsingCellularFallback ? "Cellular SIM Call" : "Voice Call",
                      style: const TextStyle(
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
                      color: isUsingCellularFallback 
                          ? Colors.blue.withOpacity(0.6)  // Blue glow for SIM calls
                          : Colors.green.withOpacity(0.6), // Green glow for internet calls
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      "${ApiConfig.baseUrl}/uploads/${widget.user.profile}",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.grey,
                      ),
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

              /// Call Status / Timer Display
              Text(
                callConnected ? formatTime(seconds) : "Calling...",
                style: TextStyle(
                  fontSize: 18,
                  color: callConnected ? Colors.greenAccent : Colors.white70,
                ),
              ),
              
              if (isUsingCellularFallback) ...[
                const SizedBox(height: 6),
                const Text(
                  "User offline. Routed via cellular network.",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                )
              ],

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

                    /// End Call (UPDATED BLOCK PLACE)
                    GestureDetector(
                      onTap: () async {
                        _terminateInternetCallChannels(); // Force-kill internet components cleanly
                        if (mounted) {
                          Navigator.pop(context); // Close calling screen layout
                        }
                      },
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

                    /// Speaker (UPDATED TO USE NATIVE CONTROLLER)
                    _buildCallButton(
                      icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: isSpeakerOn ? Colors.green : Colors.white,
                      onTap: () => toggleSpeaker(),
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