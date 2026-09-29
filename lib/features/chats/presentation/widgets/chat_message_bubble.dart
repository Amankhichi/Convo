import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/widgets/audio_message_bubble.dart';
import 'package:convo/features/chats/presentation/widgets/image_message_widget.dart';
import 'package:convo/features/chats/presentation/widgets/message_status_widget.dart';
import 'package:convo/features/chats/presentation/widgets/reply_preview_widget.dart';
import 'package:convo/features/chats/presentation/widgets/story_reply_preview_widget.dart';
import 'package:convo/features/chats/presentation/widgets/text_message_widget.dart';
import 'package:convo/features/chats/presentation/widgets/video_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool isSameSenderBelow;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onRetryMedia;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSameSenderBelow,
    required this.isSelected,
    required this.isHighlighted,
    required this.onTap,
    required this.onLongPress,
    this.onRetryMedia,
  });

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (_) {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double radius = 16.0;

    double topLeft = radius;
    double topRight = radius;
    double bottomLeft = radius;
    double bottomRight = radius;

    if (isMe) {
      bottomRight = isSameSenderBelow ? 4.0 : 4.0;
    } else {
      bottomLeft = isSameSenderBelow ? 4.0 : 4.0;
    }

    final double marginBottom = isSameSenderBelow ? 3.0 : 8.0;

    final Color effectiveBubbleColor = isHighlighted
        ? Colors.amber.withValues(alpha: 0.35)
        : (isMe
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)));

    final bool isMediaBubble = (message.type == "IMAGE" || message.type == "VIDEO") && message.storyReply == null;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.only(bottom: marginBottom),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: isMediaBubble
                  ? const EdgeInsets.all(3)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: effectiveBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeft),
                  topRight: Radius.circular(topRight),
                  bottomLeft: Radius.circular(bottomLeft),
                  bottomRight: Radius.circular(bottomRight),
                ),
                border: isHighlighted
                    ? Border.all(color: Colors.amber, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quoted Reply Preview
                  if (message.replyToContent != null &&
                      message.replyToContent!.isNotEmpty)
                    ReplyPreviewWidget(
                      replyContent: message.replyToContent!,
                      isMe: isMe,
                    ),

                  // Story Reply Preview Card
                  if (message.storyReply != null || message.type == "STORY_REPLY")
                    StoryReplyPreviewWidget(
                      storyReply: message.storyReply!,
                      textContent: message.content,
                      isMe: isMe,
                    )
                  else if (message.type == "AUDIO")
                    AudioMessageBubble(
                      audioUrl: (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
                          ? message.mediaUrl!
                          : message.content,
                      isMe: isMe,
                      isUploading: message.isUploading,
                      isFailed: message.isFailed,
                      onRetry: onRetryMedia,
                    )
                  else if (message.type == "IMAGE" ||
                      (message.mediaUrl != null &&
                          message.mediaUrl!.isNotEmpty &&
                          message.type != "VIDEO" &&
                          message.type != "AUDIO"))
                    ImageMessageWidget(
                      message: message,
                      isMe: isMe,
                      onRetry: onRetryMedia,
                    )
                  else if (message.type == "VIDEO")
                    VideoMessageWidget(
                      message: message,
                      isMe: isMe,
                      onRetry: onRetryMedia,
                    )
                  else
                    TextMessageWidget(
                      message: message,
                      isMe: isMe,
                    ),

                  const SizedBox(height: 2),

                  // Timestamp & Status Ticks Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (message.edited)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            "edited",
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: isMe ? Colors.white70 : AppColors.greyText(context),
                            ),
                          ),
                        ),
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : AppColors.greyText(context),
                        ),
                      ),
                      MessageStatusWidget(
                        message: message,
                        isMe: isMe,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
