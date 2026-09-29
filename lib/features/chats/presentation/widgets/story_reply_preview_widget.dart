import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/features/stories/presentation/pages/story_viewer_page.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';

class StoryReplyPreviewWidget extends StatelessWidget {
  final StoryReplyEntity storyReply;
  final String textContent;
  final bool isMe;

  const StoryReplyPreviewWidget({
    super.key,
    required this.storyReply,
    required this.textContent,
    required this.isMe,
  });

  void _onTapPreview(BuildContext context) async {
    if (storyReply.computedIsExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This story has expired"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    try {
      final storyRepo = sl<StoryRepository>();
      final cachedGroups = storyRepo.getStoryGroups();
      int targetGroupIdx = -1;
      int targetStoryIdx = -1;

      for (int i = 0; i < cachedGroups.length; i++) {
        final g = cachedGroups[i];
        final sIdx = g.stories.indexWhere(
          (s) => s.id.toString() == storyReply.storyId.toString(),
        );
        if (sIdx != -1) {
          targetGroupIdx = i;
          targetStoryIdx = sIdx;
          break;
        }
      }

      if (targetGroupIdx != -1 && targetStoryIdx != -1 && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewerPage(
              storyGroups: cachedGroups,
              initialGroupIndex: targetGroupIdx,
            ),
          ),
        );
        return;
      }
    } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Story unavailable or no longer active"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = storyReply.computedIsExpired;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quoted Story Box (WhatsApp / Instagram style)
        GestureDetector(
          onTap: () => _onTapPreview(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.black.withOpacity(0.2)
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(
                  color: isMe ? Colors.white70 : AppColors.primary,
                  width: 3.5,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Story Media Thumbnail (Left)
                Container(
                  width: 44,
                  height: 44,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isExpired
                      ? const Center(
                          child: Icon(
                            Icons.history_toggle_off,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        )
                      : (storyReply.mediaUrl.isNotEmpty
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    ApiConfig.sanitizeUrl(storyReply.mediaUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                if (storyReply.mediaType.toUpperCase() == 'VIDEO')
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white54,
                                size: 18,
                              ),
                            )),
                ),
                const SizedBox(width: 8),

                // Quoted Header & Info
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: isMe ? Colors.white70 : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Replied to story",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isMe ? Colors.white70 : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isExpired
                            ? "Story expired"
                            : (storyReply.mediaType.toUpperCase() == 'VIDEO'
                                ? "📹 Video Story"
                                : "📷 Photo Story"),
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isExpired
                              ? Colors.redAccent
                              : (isMe
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textColor(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // User Reply Text (underneath quoted box)
        if (textContent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Text(
              textContent,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.textColor(context),
              ),
            ),
          ),
      ],
    );
  }
}
