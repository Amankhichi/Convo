import 'package:convo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ReplyPreviewWidget extends StatelessWidget {
  final String replyContent;
  final bool isMe;
  final VoidCallback? onCancel;

  const ReplyPreviewWidget({
    super.key,
    required this.replyContent,
    required this.isMe,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : AppColors.primary,
            width: 3.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              replyContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isMe ? Colors.white70 : AppColors.textColor(context),
              ),
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
