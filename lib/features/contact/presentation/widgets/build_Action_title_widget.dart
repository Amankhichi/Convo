import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class BuildActionTitleWidget extends StatelessWidget {
  const BuildActionTitleWidget({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textColor(context),
        ),
      ),
      onTap: onTap,
    );
  }
}