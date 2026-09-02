import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text("Voice / Video Call")),
      body: const Center(
        child: Text("WebRTC Call Screen Placeholder"),
      ),
    );
  }
}
