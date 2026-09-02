import 'dart:async';
import 'package:flutter/material.dart';
import 'package:convo/core/utils/logger.dart';
import 'package:convo/features/presence/domain/entities/presence_entity.dart';
import 'package:convo/features/presence/domain/repositories/presence_repository.dart';

class PresenceManager extends WidgetsBindingObserver {
  final PresenceRepository _presenceRepository;

  Timer? _timer;
  bool _isRunning = false;
  bool _isObserverRegistered = false;

  final ValueNotifier<PresenceEntity?> currentUserPresence = ValueNotifier<PresenceEntity?>(null);

  PresenceManager(this._presenceRepository);

  /// Starts the heartbeat engine, registers lifecycle observer, sends immediate heartbeat,
  /// and schedules 30-second periodic ticks.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    if (!_isObserverRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _isObserverRegistered = true;
    }

    AppLogger.d("[PRESENCE] Heartbeat started");
    sendHeartbeat();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendHeartbeat();
    });
  }

  /// Stops the periodic heartbeat timer and removes lifecycle observer.
  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;

    if (_isObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserverRegistered = false;
    }

    AppLogger.d("[PRESENCE] Heartbeat stopped");
  }

  /// Restarts the heartbeat cycle cleanly.
  void restart() {
    stop();
    start();
  }

  /// Sends a single heartbeat request to POST /api/users/presence/heartbeat
  Future<PresenceEntity?> sendHeartbeat() async {
    if (!_isRunning) return null;
    try {
      AppLogger.d("[PRESENCE] Sending heartbeat");
      final presence = await _presenceRepository.sendHeartbeat();
      currentUserPresence.value = presence;

      AppLogger.d("[PRESENCE] Heartbeat success");
      AppLogger.d("[PRESENCE] Status: ${presence.status}");
      AppLogger.d("[PRESENCE] Last Seen: ${presence.lastSeen}");

      return presence;
    } catch (e) {
      AppLogger.e("[PRESENCE] Heartbeat failed: $e");
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isRunning) {
          AppLogger.d("[PRESENCE] App resumed -> Sending immediate heartbeat and restarting timer");
          sendHeartbeat();
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 30), (_) {
            sendHeartbeat();
          });
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        AppLogger.d("[PRESENCE] App paused/inactive -> Pausing heartbeat timer");
        _timer?.cancel();
        _timer = null;
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _timer?.cancel();
        _timer = null;
        break;
    }
  }

  /// Cleanup resources
  void dispose() {
    stop();
    currentUserPresence.dispose();
  }
}
