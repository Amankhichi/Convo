import 'package:flutter/material.dart';

class GestureDetectorMoreVert extends StatelessWidget {
  const GestureDetectorMoreVert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: const Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}