import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserProfilePreviewDialog extends StatelessWidget {
  final int userId;
  final String name;
  final String phone;
  final String image;
  final String about;
  final bool isOnline;
  final int chatId;

  const UserProfilePreviewDialog({
    super.key,
    required this.userId,
    required this.name,
    required this.phone,
    required this.image,
    required this.about,
    required this.isOnline,
    this.chatId = 0,
  });

  static void show(
    BuildContext context, {
    required int userId,
    required String name,
    required String phone,
    required String image,
    required String about,
    required bool isOnline,
    int chatId = 0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => UserProfilePreviewDialog(
        userId: userId,
        name: name,
        phone: phone,
        image: image,
        about: about,
        isOnline: isOnline,
        chatId: chatId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: dialogBg,
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered Profile Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  backgroundImage: image.isNotEmpty
                      ? NetworkImage(ApiConfig.sanitizeUrl(image))
                      : null,
                  child: image.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dialogBg,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Online / Offline Status
            Text(
              isOnline ? "Online" : "Offline",
              style: TextStyle(
                fontSize: 13,
                color: isOnline ? Colors.green : AppColors.greyText(context),
                fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),

            // About / Bio
            if (about.isNotEmpty)
              Text(
                about,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.greyText(context),
                ),
              ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Quick Action Buttons (Call, Video, Message, Info)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.call,
                  label: "Call",
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.calling);
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.videocam,
                  label: "Video",
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.calling);
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.chat,
                  label: "Message",
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      RouteNames.chat,
                      arguments: {
                        "chatId": chatId,
                        "targetUserId": userId,
                        "contactName": name,
                        "contactPhone": phone,
                        "contactImage": image,
                        "contactAbout": about,
                        "online": isOnline,
                      },
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.info_outline,
                  label: "Info",
                  color: Colors.purple.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      RouteNames.contactProfile,
                      arguments: {
                        "name": name,
                        "phone": phone,
                        "image": image,
                        "about": about,
                        "online": isOnline,
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
