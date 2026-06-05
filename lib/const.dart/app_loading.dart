import 'package:convo/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size = 35,
    this.color = AppColors.primary,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}