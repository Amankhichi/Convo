import 'dart:io';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/pages/image_viewer_page.dart';
import 'package:flutter/material.dart';

class ImageMessageWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback? onRetry;

  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final mediaUrl = message.mediaUrl ?? "";
    final isNetwork = mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://');

    return GestureDetector(
      onTap: () {
        if (message.isFailed && onRetry != null) {
          onRetry!();
        } else if (!message.isUploading && mediaUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerPage(imageUrl: mediaUrl),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                isNetwork
                    ? Image.network(
                        mediaUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 220,
                            height: 180,
                            color: Colors.black12,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        },
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 220,
                          height: 180,
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      )
                    : Image.file(
                        File(mediaUrl),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 220,
                          height: 180,
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                if (message.isUploading)
                  Container(
                    width: 220,
                    height: 220,
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            "Uploading...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (message.isFailed)
                  Container(
                    width: 220,
                    height: 220,
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
                          SizedBox(height: 6),
                          Text(
                            "Upload failed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Tap to retry",
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.content.isNotEmpty && message.content != "📷 Image")
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : AppColors.textColor(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
