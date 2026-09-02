import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/utils/logger.dart';
import 'package:flutter/material.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final bool isUploading;
  final bool isFailed;
  final VoidCallback? onRetry;

  const AudioMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
    this.isUploading = false,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  static AudioPlayer? _activeGlobalPlayer;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_activeGlobalPlayer == _audioPlayer) {
      _activeGlobalPlayer = null;
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (widget.isUploading || widget.isFailed) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      // Stop any other active voice message playing
      if (_activeGlobalPlayer != null && _activeGlobalPlayer != _audioPlayer) {
        await _activeGlobalPlayer?.pause();
      }
      _activeGlobalPlayer = _audioPlayer;

      String url = widget.audioUrl.trim();
      if (url.isEmpty) return;

      if (url.startsWith('{') && url.contains('http')) {
        final match = RegExp(r'https?://[^\s,}]+').firstMatch(url);
        if (match != null) {
          url = match.group(0)!;
        }
      }

      url = ApiConfig.sanitizeUrl(url);
      if (url.startsWith('/')) {
        url = ApiConfig.baseUrl + url;
      }

      AppLogger.d("[AUDIO] PLAY START url=$url");

      final isNetwork = url.startsWith('http://') || url.startsWith('https://');

      if (isNetwork) {
        await _audioPlayer.play(UrlSource(url));
      } else {
        final file = File(url);
        if (await file.exists()) {
          await _audioPlayer.play(DeviceFileSource(url));
        } else {
          AppLogger.e("[AUDIO] Local audio file not found: $url");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Audio file unavailable")),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.e("[AUDIO] AudioPlayer exception: $e");
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isMe ? Colors.white : AppColors.textColor(context);
    final accentColor = widget.isMe ? Colors.white : AppColors.primary;

    if (widget.isUploading) {
      return Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Uploading audio...",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.isFailed) {
      return Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onRetry,
              child: const Icon(Icons.refresh, color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Upload Failed - Tap to retry",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent.shade100,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _toggleAudio,
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: accentColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                    overlayShape: SliderComponentShape.noOverlay,
                    trackHeight: 2.5,
                    activeTrackColor: accentColor,
                    inactiveTrackColor: accentColor.withValues(alpha: 0.3),
                    thumbColor: accentColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble() > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value: _position.inMilliseconds.toDouble().clamp(
                          0.0,
                          _duration.inMilliseconds.toDouble() > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                        ),
                    onChanged: (val) async {
                      try {
                        await _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                      } catch (e) {
                        AppLogger.e("Seek error: $e");
                      }
                    },
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(fontSize: 9, color: textColor),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(fontSize: 9, color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
