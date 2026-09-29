import 'dart:async';
import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  AudioPlayer? _audioPlayer;
  bool _isRinging = false;
  bool get isRinging => _isRinging;

  Future<void> startIncomingRingtone() async {
    if (_isRinging) {
      _log("Ringtone is already playing. Skipping duplicate start request.");
      return;
    }

    _isRinging = true;
    _log("[CALL-DEBUG][RECEIVER] RINGTONE_START");

    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.setVolume(1.0);
      try {
        await _audioPlayer!.play(
          UrlSource("https://raw.githubusercontent.com/w3c/web-platform-tests/master/media-source/mp3/test.mp3"),
          volume: 1.0,
        ).timeout(const Duration(seconds: 3), onTimeout: () {
          _log("Ringtone playback timed out (offline/slow connection). Continuing call flow without sound.");
        });
      } catch (playErr) {
        _log("UrlSource ringtone playback deferred or offline: $playErr");
      }
    } catch (e) {
      _log("Error starting incoming ringtone: $e");
    }
  }

  Future<void> startOutgoingRingtone() async {
    if (_isRinging) {
      _log("Ringtone is already playing. Skipping duplicate start request.");
      return;
    }

    _isRinging = true;
    _log("[CALL-DEBUG][CALLER] RINGING_SOUND_START");

    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer!.setVolume(0.8);
      try {
        await _audioPlayer!.play(
          UrlSource("https://raw.githubusercontent.com/w3c/web-platform-tests/master/media-source/mp3/test.mp3"),
          volume: 0.8,
        ).timeout(const Duration(seconds: 3), onTimeout: () {
          _log("Outgoing ringtone playback timed out. Continuing call flow.");
        });
      } catch (playErr) {
        _log("UrlSource ringtone playback deferred or offline: $playErr");
      }
    } catch (e) {
      _log("Error starting outgoing ringtone: $e");
    }
  }

  Future<void> startRinging() async {
    await startIncomingRingtone();
  }

  Future<void> stopRinging() async {
    if (!_isRinging && _audioPlayer == null) return;

    _isRinging = false;
    _log("[CALL-DEBUG] RINGING_SOUND_STOP");

    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();
    } catch (e) {
      _log("Error stopping ringtone: $e");
    } finally {
      _audioPlayer = null;
    }
  }

  void dispose() {
    stopRinging();
  }

  void _log(String message) {
    developer.log("[RingtoneService] $message");
  }
}
