import 'package:flutter/material.dart';

class CameraGridOverlay extends StatelessWidget {
  const CameraGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
                Expanded(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white12)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
