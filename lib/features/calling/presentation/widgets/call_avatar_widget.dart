import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CallAvatarWidget extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double radius;
  final bool isRinging;

  const CallAvatarWidget({
    super.key,
    required this.name,
    required this.imageUrl,
    this.radius = 60,
    this.isRinging = false,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedUrl = ApiConfig.sanitizeUrl(imageUrl);
    final hasImage = sanitizedUrl.isNotEmpty;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.all(isRinging ? 8 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.15),
        border: isRinging
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 3)
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: hasImage ? NetworkImage(sanitizedUrl) : null,
        child: !hasImage
            ? Text(
                initial,
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
