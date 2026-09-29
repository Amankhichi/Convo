import 'dart:developer' as developer;
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallLifecycleObserver extends StatefulWidget {
  final Widget child;

  const CallLifecycleObserver({super.key, required this.child});

  @override
  State<CallLifecycleObserver> createState() => _CallLifecycleObserverState();
}

class _CallLifecycleObserverState extends State<CallLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log("[CallLifecycleObserver] App lifecycle state changed to: $state");

    final callBloc = context.read<CallBloc>();
    final currentStatus = callBloc.state.status;

    if (state == AppLifecycleState.resumed) {
      developer.log("[CallLifecycleObserver] App resumed. Current call status: $currentStatus");
      if (currentStatus.isInCall) {
        // App resumed while call is active/connecting: ensure socket stays alive
        callBloc.add(const InitializeCallingServiceEvent());
      }
    } else if (state == AppLifecycleState.paused) {
      developer.log("[CallLifecycleObserver] App paused/backgrounded.");
      // Do NOT destroy active WebRTC call on background
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
