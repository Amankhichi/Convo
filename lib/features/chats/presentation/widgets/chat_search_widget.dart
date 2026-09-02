import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onCloseSearch;
  final List<MessageEntity> currentMessages;
  final int targetUserId;
  final String targetName;
  final Function(MessageEntity targetMsg, List<MessageEntity> messages) onSelectResult;

  const ChatSearchWidget({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onQueryChanged,
    required this.onCloseSearch,
    required this.currentMessages,
    required this.targetUserId,
    required this.targetName,
    required this.onSelectResult,
  });

  PreferredSizeWidget buildSearchAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: onCloseSearch,
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        style: TextStyle(color: AppColors.textColor(context), fontSize: 16),
        decoration: InputDecoration(
          hintText: "Search messages...",
          hintStyle: TextStyle(color: AppColors.greyText(context)),
          border: InputBorder.none,
        ),
        onChanged: onQueryChanged,
      ),
      actions: [
        if (searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.primary),
            onPressed: () {
              searchController.clear();
              onQueryChanged("");
            },
          ),
      ],
    );
  }

  Widget buildOverlay(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 64, color: AppColors.greyText(context).withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                "Search messages in this chat",
                style: TextStyle(color: AppColors.greyText(context), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final results = currentMessages.where((msg) {
      final textMatch = msg.content.toLowerCase().contains(query);
      final mediaMatch = (msg.type == "IMAGE" && "photo image".contains(query)) ||
          (msg.type == "VIDEO" && "video".contains(query)) ||
          (msg.type == "AUDIO" && "audio voice".contains(query));
      return textMatch || mediaMatch;
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.greyText(context).withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'No messages found for "$searchQuery"',
                style: TextStyle(color: AppColors.greyText(context), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, idx) {
          final msg = results[idx];
          final isMe = msg.senderId != targetUserId;
          final senderLabel = isMe ? "You" : targetName;

          String timeStr = "";
          try {
            final dt = DateTime.parse(msg.createdAt).toLocal();
            timeStr = DateFormat("MMM d, h:mm a").format(dt);
          } catch (_) {
            timeStr = msg.createdAt;
          }

          String previewText = msg.content;
          if (previewText.isEmpty) {
            if (msg.type == "IMAGE") previewText = "🖼 Photo";
            if (msg.type == "VIDEO") previewText = "🎥 Video";
            if (msg.type == "AUDIO") previewText = "🎵 Audio";
          }

          return ListTile(
            onTap: () => onSelectResult(msg, currentMessages),
            leading: CircleAvatar(
              backgroundColor: isMe
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15),
              child: Icon(
                msg.type == "IMAGE"
                    ? Icons.image
                    : (msg.type == "VIDEO"
                        ? Icons.videocam
                        : (msg.type == "AUDIO" ? Icons.audiotrack : Icons.message_rounded)),
                color: isMe ? AppColors.primary : Colors.grey.shade700,
                size: 20,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  senderLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 11, color: AppColors.greyText(context)),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                previewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textColor(context), fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildOverlay(context);
  }
}
