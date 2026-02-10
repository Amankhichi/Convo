import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:convo/core/const.dart/app_colors.dart';

class Avatar extends StatefulWidget {
  const Avatar({super.key});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  String avatarExpression = "normal";

  // Example face data (replace with ML Kit face result)
  double smilingProbability = 0.0;

  void updateExpression(double smile) {
    setState(() {
      if (smile > 0.7) {
        avatarExpression = "smile";
      } else {
        avatarExpression = "normal";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: ClipOval(
          child: Lottie.asset(
            avatarExpression == "smile"
                ? "assets/lottie/smile.json"
                : "assets/lottie/normal.json",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
