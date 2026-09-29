import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/presentation/bloc/story_bloc.dart';
import 'package:convo/features/stories/presentation/bloc/story_event.dart';
import 'package:convo/features/stories/presentation/bloc/story_state.dart';
import 'package:convo/features/stories/presentation/pages/story_camera_page.dart';
import 'package:convo/features/stories/presentation/pages/story_editor_page.dart';
import 'package:convo/features/stories/presentation/pages/story_viewer_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryBarWidget extends StatefulWidget {
  const StoryBarWidget({super.key});

  @override
  State<StoryBarWidget> createState() => _StoryBarWidgetState();
}

class _StoryBarWidgetState extends State<StoryBarWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localStorage = sl<LocalStorage>();
    final myName = localStorage.getString(StorageKeys.name) ?? "My Story";
    final myImage = localStorage.getString(StorageKeys.profileImage) ?? "";

    return BlocProvider(
      create: (_) => sl<StoryBloc>()..add(const FetchStoryFeedEvent()),
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          List<UserStoryGroupEntity> storyGroups = [];
          UserStoryGroupEntity? myStoryGroup;

          if (state is StoryFeedLoaded) {
            storyGroups = state.storyGroups;
            myStoryGroup = state.myStories;
          }

          final hasMyStory = myStoryGroup != null && myStoryGroup.activeStories.isNotEmpty;

          return Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // "Your Story" Item
                GestureDetector(
                  onTap: () {
                    if (hasMyStory) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryViewerPage(
                            storyGroups: [myStoryGroup!],
                            initialGroupIndex: 0,
                          ),
                        ),
                      );
                    } else {
                      _openAddStoryFlow(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: hasMyStory ? AppColors.primary : (isDark ? Colors.white38 : Colors.grey.shade400),
                                  width: hasMyStory ? 2.5 : 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: const Color(0xFFE2D6FF),
                                  backgroundImage: myImage.isNotEmpty
                                      ? NetworkImage(ApiConfig.sanitizeUrl(myImage))
                                      : null,
                                  child: myImage.isEmpty
                                      ? Text(
                                          myName.isNotEmpty ? myName[0].toUpperCase() : "M",
                                          style: const TextStyle(
                                            color: Color(0xFF5B21B6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _openAddStoryFlow(context),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isDark ? const Color(0xFF131317) : Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your Story",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact Story Circles
                ...storyGroups.where((g) => g.userId != 0).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final group = entry.value;
                  final hasUnseen = group.hasUnseenStories;
                  final displayName = group.userName.split(' ').first;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryViewerPage(
                            storyGroups: storyGroups.where((g) => g.userId != 0).toList(),
                            initialGroupIndex: idx,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: hasUnseen ? Colors.green : Colors.grey.shade500,
                                width: hasUnseen ? 2.5 : 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFFE2D6FF),
                                backgroundImage: group.userImage.isNotEmpty
                                    ? NetworkImage(ApiConfig.sanitizeUrl(group.userImage))
                                    : null,
                                child: group.userImage.isEmpty
                                    ? Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                                        style: const TextStyle(
                                          color: Color(0xFF5B21B6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 66,
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: hasUnseen ? FontWeight.bold : FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context, {required bool isVideo}) async {
    final picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

    if (file != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryEditorPage(
            mediaPath: file.path,
            mediaType: isVideo ? 'VIDEO' : 'IMAGE',
          ),
        ),
      );
    }
  }

  void _openAddStoryFlow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text("Camera (Photo / Video)", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Open ConVo Story Camera"),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryCameraPage()));
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text("Choose Photo from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Select image from media gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery(context, isVideo: false);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.videocam, color: Colors.white),
                ),
                title: const Text("Choose Video from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Select video from media gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery(context, isVideo: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
