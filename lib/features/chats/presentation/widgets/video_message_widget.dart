import 'dart:io';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/pages/video_viewer_page.dart';
import 'package:flutter/material.dart';

class VideoMessageWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final VoidCallback? onRetry;

  const VideoMessageWidget({
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
              builder: (_) => VideoViewerPage(videoUrl: mediaUrl),
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
                Container(
                  width: 220,
                  height: 180,
                  color: Colors.black26,
                  child: isNetwork
                      ? Image.network(
                          mediaUrl,
                          width: 220,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Center(
                            child: Icon(Icons.videocam, size: 48, color: Colors.white60),
                          ),
                        )
                      : Image.file(
                          File(mediaUrl),
                          width: 220,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Center(
                            child: Icon(Icons.videocam, size: 48, color: Colors.white60),
                          ),
                        ),
                ),
                if (!message.isUploading && !message.isFailed)
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                if (message.isUploading)
                  Container(
                    width: 220,
                    height: 180,
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            "Uploading video...",
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
                    height: 180,
                    color: Colors.black87,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                          SizedBox(height: 4),
                          Text(
                            "Upload failed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Tap to retry",
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.content.isNotEmpty && message.content != "🎥 Video")
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
