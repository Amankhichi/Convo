import 'package:flutter/material.dart';

class CameraFocusIndicator extends StatelessWidget {
  final Offset point;

  const CameraFocusIndicator({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: point.dx - 30,
      top: point.dy - 30,
      child: IgnorePointer(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.center_focus_weak, color: Colors.amber, size: 24),
          ),
        ),
      ),
    );
  }
}
