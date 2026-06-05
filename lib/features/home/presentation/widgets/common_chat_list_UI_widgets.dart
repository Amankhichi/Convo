import 'package:convo/const.dart/api_config.dart';
import 'package:convo/const.dart/app_colors.dart';
import 'package:convo/core/custom/custom_text.dart';
import 'package:convo/features/auth/presentation/widgets/full_image_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommonChatListUiWidgets extends StatelessWidget {
  final dynamic chat;
  final dynamic user;

  final bool selected;
  final bool showUnread;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CommonChatListUiWidgets({
    super.key,
    required this.chat,
    required this.user,
    required this.selected,
    required this.showUnread,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;

    if (diff == 0) {
      return DateFormat('hh:mm a').format(date);
    }

    if (diff == 1) {
      return "Yesterday";
    }

    return DateFormat('dd MMM').format(date);
  }

void _showProfileDialog(BuildContext context, dynamic user) {
  final imageUrl = "${ApiConfig.baseUrl}/uploads/${user.profile}";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF121212),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HANDLE
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            /// PROFILE IMAGE
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullScreenImagePage(image: imageUrl),
                  ),
                );
              },
              child: Hero(
                tag: imageUrl,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// NAME
            Text(
              user.name ?? "Unknown",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            /// STATUS
            Text(
              "Online",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 25),

            /// ROW 1
            Row(
              children: [
                Expanded(
                  child: _pillButton(
                    icon: Icons.call,
                    label: "Call",
                    color: const Color(0xFF25D366),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pillButton(
                    icon: Icons.chat,
                    label: "Chat",
                    color: const Color(0xFF4DA3FF),
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ROW 2
            Row(
              children: [
                Expanded(
                  child: _pillButton(
                    icon: Icons.videocam,
                    label: "Video",
                    color: const Color(0xFF8B5CF6),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pillButton(
                    icon: Icons.info,
                    label: "Info",
                    color: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Widget _pillButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.20),
            color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
 
 


  @override
  Widget build(BuildContext context) {
    final hasProfile =
        user.profile.isNotEmpty && user.profile.toString().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),

          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
        ),

        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _showProfileDialog(context, user);
                  },

                  child: Hero(
                    tag: "${ApiConfig.baseUrl}/uploads/${user.profile}",

                    child: Container(
                      padding: const EdgeInsets.all(2),

                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [Color(0xff4F46E5), Color(0xff7C3AED)],
                        ),
                      ),

                      child: CircleAvatar(
                        radius: 31,

                        backgroundColor: Colors.grey.shade200,

                        backgroundImage: hasProfile
                            ? NetworkImage(
                                "${ApiConfig.baseUrl}/uploads/${user.profile}",
                              )
                            : null,

                        child: !hasProfile
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 2,
                  bottom: 2,

                  child: Container(
                    height: 15,
                    width: 15,

                    decoration: BoxDecoration(
                      color: user.online ? Colors.green : Colors.grey,

                      shape: BoxShape.circle,

                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),

                if (selected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.35),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    user.name.toString().trim().isEmpty
                        ? user.phone.toString()
                        : user.name.toString(),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.iconColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    showUnread
                        ? "${chat.unSeenCount} new message${chat.unSeenCount > 1 ? "s" : ""}"
                        : chat.message.toString(),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.iconColor,

                      fontWeight: showUnread
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                if (showUnread)
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.primary,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      chat.unSeenCount.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                CustomText(
                  text: _formatDate(chat.createdAt),

                  bold: FontWeight.w500,
                  size: 11,

                  clr: showUnread ? AppColors.iconColor : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
}
