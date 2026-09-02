import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:convo/features/chats/presentation/bloc/chat_event.dart';
import 'package:convo/features/chats/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageList extends StatelessWidget {
  final List<MessageEntity> messages;
  final int targetUserId;
  final ScrollController scrollController;
  final bool isSelectionMode;
  final Set<int> selectedMessageIds;
  final String? highlightedClientMsgId;
  final int? highlightedMsgId;
  final bool hasUnreadBelow;
  final VoidCallback onScrollToBottom;
  final Function(MessageEntity msg) onMessageTap;
  final Function(MessageEntity msg) onMessageLongPress;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.targetUserId,
    required this.scrollController,
    required this.isSelectionMode,
    required this.selectedMessageIds,
    this.highlightedClientMsgId,
    this.highlightedMsgId,
    required this.hasUnreadBelow,
    required this.onScrollToBottom,
    required this.onMessageTap,
    required this.onMessageLongPress,
  });

  String _formatDateHeader(String isoString) {
    if (isoString.isEmpty) return "";
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDate = DateTime(date.year, date.month, date.day);

      if (msgDate == today) {
        return "Today";
      } else if (msgDate == today.subtract(const Duration(days: 1))) {
        return "Yesterday";
      } else {
        return DateFormat('MMMM d, yyyy').format(date);
      }
    } catch (_) {
      return "";
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index == messages.length - 1) return true;
    try {
      final current = DateTime.parse(messages[index].createdAt).toLocal();
      final next = DateTime.parse(messages[index + 1].createdAt).toLocal();
      return current.year != next.year ||
          current.month != next.month ||
          current.day != next.day;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.greyText(context),
            ),
            const SizedBox(height: 12),
            Text(
              "No messages yet. Say hi!",
              style: TextStyle(
                color: AppColors.greyText(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId != targetUserId;

            bool isSameSenderBelow = false;
            if (index > 0) {
              final belowMsg = messages[index - 1];
              isSameSenderBelow = (belowMsg.senderId == message.senderId);
            }

            final bool showDateHeader = _shouldShowDateHeader(index);
            final bool isSelected = selectedMessageIds.contains(message.id);

            final bool isHighlighted =
                (highlightedClientMsgId != null &&
                    highlightedClientMsgId!.isNotEmpty &&
                    message.clientMessageId == highlightedClientMsgId) ||
                (highlightedMsgId != null &&
                    highlightedMsgId != 0 &&
                    message.id == highlightedMsgId);

            return Column(
              key: ValueKey(message.id != 0 ? message.id : message.clientMessageId ?? index),
              children: [
                if (showDateHeader)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDateHeader(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyText(context),
                      ),
                    ),
                  ),
                ChatMessageBubble(
                  message: message,
                  isMe: isMe,
                  isSameSenderBelow: isSameSenderBelow,
                  isSelected: isSelected,
                  isHighlighted: isHighlighted,
                  onTap: () => onMessageTap(message),
                  onLongPress: () => onMessageLongPress(message),
                  onRetryMedia: () {
                    context.read<ChatBloc>().add(RetrySendMessageEvent(message));
                  },
                ),
              ],
            );
          },
        ),
        if (hasUnreadBelow)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.primary,
              onPressed: onScrollToBottom,
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
