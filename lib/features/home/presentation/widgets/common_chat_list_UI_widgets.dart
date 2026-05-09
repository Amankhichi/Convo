import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/app_colors.dart';
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
    ).difference(
      DateTime(date.year, date.month, date.day),
    ).inDays;

    if (diff == 0) {
      return DateFormat('hh:mm a').format(date);
    }

    if (diff == 1) {
      return "Yesterday";
    }

    return DateFormat('dd MMM').format(date);
  }

  void _showProfileDialog(
    BuildContext context,
    dynamic user,
  ) {
    final imageUrl =
        "${ApiConfig.baseUrl}/uploads/${user.profile}";

    showDialog(
      context: context,
      barrierColor: Colors.black87,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(horizontal: 35),

          child: Container(
            width: 280,

            decoration: BoxDecoration(
              border: Border.all(
                width: 4,
                color: AppColors.primary,
              ),

              color: const Color.fromARGB(
                255,
                222,
                204,
                204,
              ),

              borderRadius: BorderRadius.circular(25),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FullScreenImagePage(
                              image: imageUrl,
                            ),
                      ),
                    );
                  },

                  child: Hero(
                    tag: imageUrl,

                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),

                      child: Image.network(
                        imageUrl,

                        height: 300,
                        width: double.infinity,

                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 300,

                            color: Colors.grey.shade900,

                            alignment: Alignment.center,

                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 80,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      _dialogButton(
                        icon: Icons.call_rounded,
                        color: Colors.green,
                      ),

                      _dialogButton(
                        icon: Icons.chat_rounded,
                        color: Colors.blue,
                      ),

                      _dialogButton(
                        icon: Icons.videocam_rounded,
                        color: Colors.purple,
                      ),

                      _dialogButton(
                        icon: Icons.info_outline_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogButton({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 50,
      width: 50,

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile =
        user.profile.isNotEmpty &&
        user.profile.toString().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,

      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 10),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),

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
                    tag:
                        "${ApiConfig.baseUrl}/uploads/${user.profile}",

                    child: Container(
                      padding: const EdgeInsets.all(2),

                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [
                            Color(0xff4F46E5),
                            Color(0xff7C3AED),
                          ],
                        ),
                      ),

                      child: CircleAvatar(
                        radius: 31,

                        backgroundColor:
                            Colors.grey.shade200,

                        backgroundImage: hasProfile
                            ? NetworkImage(
                                "${ApiConfig.baseUrl}/uploads/${user.profile}",
                              )
                            : null,

                        child: !hasProfile
                            ? const Icon(
                                Icons.person,
                                color: Colors.grey,
                              )
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
                      color: user.online
                          ? Colors.green
                          : Colors.grey,

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                if (selected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.black.withOpacity(.35),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    user.name
                            .toString()
                            .trim()
                            .isEmpty
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
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                if (showUnread)
                  Container(
                    margin:
                        const EdgeInsets.only(bottom: 5),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.primary,

                      borderRadius:
                          BorderRadius.circular(20),
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

                  clr: showUnread
                      ? AppColors.iconColor
                      : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}