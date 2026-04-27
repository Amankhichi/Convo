import 'package:flutter/material.dart';

class ChatBodyContainer extends StatelessWidget {
  final bool Function(BuildContext) isDeviceThemeDark; // ✅ Expects FUNCTION
  final Widget child;

  const ChatBodyContainer({
    Key? key,
    required this.isDeviceThemeDark, // ✅ Function parameter
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: isDeviceThemeDark(context) // ✅ Calls function correctly
            ? const DecorationImage(
                image: AssetImage("assests/wallpapers/wallpaper2.jpg"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            : const DecorationImage(
                image: AssetImage("assests/wallpapers/LightThem.png"),
                fit: BoxFit.fitWidth,
              ),
      ),
      child: child,
    );
  }
}