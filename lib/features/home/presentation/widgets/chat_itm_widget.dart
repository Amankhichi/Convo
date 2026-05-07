import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class ChatItemWidget extends StatelessWidget {
  final dynamic chat;
  final dynamic user;
  final bool isSelected;
  final bool showUnread;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onProfileTap;

  const ChatItemWidget({
    super.key,
    required this.chat,
    required this.user,
    required this.isSelected,
    required this.showUnread,
    required this.onTap,
    required this.onLongPress,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: (user.profile.isNotEmpty)
                        ? NetworkImage(user.profile)
                        : null,
                    child: user.profile.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),

                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: user.online ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),

                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black45,
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
                    user.name.isEmpty ? user.phone : user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    showUnread
                        ? "${chat.unSeenCount} new message"
                        : chat.message ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white,),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                if (showUnread)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.unSeenCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
