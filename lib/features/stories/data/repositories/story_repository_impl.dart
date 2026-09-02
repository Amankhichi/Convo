import 'dart:convert';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/stories/data/models/story_model.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final LocalStorage _localStorage;
  static const String _storageKey = 'cached_user_stories';

  StoryRepositoryImpl(this._localStorage);

  @override
  List<UserStoryGroupEntity> getStoryGroups() {
    final jsonString = _localStorage.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final groups = decoded
            .map((item) => UserStoryGroupModel.fromJson(item as Map<String, dynamic>))
            .where((g) => g.activeStories.isNotEmpty)
            .toList();
        return groups;
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> markStoryAsSeen(int userId, String storyId) async {
    final currentGroups = getStoryGroups();
    final groupIndex = currentGroups.indexWhere((g) => g.userId == userId);

    if (groupIndex != -1) {
      final group = currentGroups[groupIndex];
      final updatedStories = group.stories.map((s) {
        if (s.id == storyId) {
          return s.copyWith(isSeen: true);
        }
        return s;
      }).toList();

      final updatedGroup = UserStoryGroupEntity(
        userId: group.userId,
        userName: group.userName,
        userImage: group.userImage,
        stories: updatedStories,
      );

      currentGroups[groupIndex] = updatedGroup;
      await _saveGroups(currentGroups);
    }
  }

  @override
  Future<void> addStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
  }) async {
    final currentGroups = getStoryGroups();
    final now = DateTime.now().toIso8601String();
    final newStory = StoryItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      createdAt: now,
      isSeen: true,
    );

    // Check if my story group exists (my userId = 0 / me)
    final groupIndex = currentGroups.indexWhere((g) => g.userId == 0);
    if (groupIndex != -1) {
      final group = currentGroups[groupIndex];
      final updatedGroup = UserStoryGroupEntity(
        userId: 0,
        userName: "My Story",
        userImage: group.userImage,
        stories: [...group.stories, newStory],
      );
      currentGroups[groupIndex] = updatedGroup;
    } else {
      currentGroups.insert(
        0,
        UserStoryGroupEntity(
          userId: 0,
          userName: "My Story",
          userImage: "",
          stories: [newStory],
        ),
      );
    }

    await _saveGroups(currentGroups);
  }

  Future<void> _saveGroups(List<UserStoryGroupEntity> groups) async {
    final models = groups.map((g) {
      return UserStoryGroupModel(
        userId: g.userId,
        userName: g.userName,
        userImage: g.userImage,
        stories: g.stories,
      ).toJson();
    }).toList();

    await _localStorage.setString(_storageKey, jsonEncode(models));
  }
}
