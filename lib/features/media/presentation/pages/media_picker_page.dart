import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class MediaPickerPage extends StatelessWidget {
  const MediaPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text("Media Picker")),
      body: const Center(
        child: Text("Media Capture & Selector Placeholder"),
      ),
    );
  }
}
