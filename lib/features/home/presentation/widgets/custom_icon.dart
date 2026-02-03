import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 18,
    this.clr = const Color(0xFF0088CC),
  });

  final IconData icon;
  final double size;
  final Color clr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(
        icon,
        color: clr,
        size: size,
      ),
    );
  }
}
