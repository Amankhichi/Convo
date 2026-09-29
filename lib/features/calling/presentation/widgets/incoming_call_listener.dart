import 'dart:developer' as developer;
import 'package:convo/app/router/app_router.dart';
import 'package:convo/features/calling/domain/entities/call_status.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/bloc/call_event.dart';
import 'package:convo/features/calling/presentation/bloc/call_state.dart';
import 'package:convo/features/calling/presentation/pages/call_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomingCallListener extends StatefulWidget {
  final Widget child;

  const IncomingCallListener({super.key, required this.child});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  bool _isCallPageActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CallBloc>().add(const InitializeCallingServiceEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallBloc, CallState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isInCall && !_isCallPageActive) {
          _isCallPageActive = true;
          developer.log("[CALL-DEBUG][RECEIVER] INCOMING_CALL_UI_OPEN");
          final navState = AppRouter.navigatorKey.currentState ?? Navigator.maybeOf(context);
          if (navState != null) {
            navState.push(
              MaterialPageRoute(builder: (_) => const CallPage()),
            ).then((_) {
              _isCallPageActive = false;
            });
          } else {
            _isCallPageActive = false;
          }
        }
      },
      child: widget.child,
    );
  }
}
