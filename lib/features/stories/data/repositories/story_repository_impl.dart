import 'package:convo/features/stories/data/datasources/story_local_datasource.dart';
import 'package:convo/features/stories/data/datasources/story_remote_datasource.dart';
import 'package:convo/features/stories/data/models/story_model.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;
  final StoryLocalDataSource _localDataSource;

  StoryRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  List<UserStoryGroupEntity> getStoryGroups() {
    return List<UserStoryGroupEntity>.from(_localDataSource.getCachedStoryGroups());
  }

  @override
  Future<List<UserStoryGroupEntity>> fetchStoryFeed({int page = 0, int limit = 20}) async {
    try {
      final remoteFeed = await _remoteDataSource.fetchFeed(page: page, limit: limit);
      if (remoteFeed.isNotEmpty) {
        await _localDataSource.saveStoryGroups(remoteFeed);
        return List<UserStoryGroupEntity>.from(remoteFeed);
      }
    } catch (_) {}

    return getStoryGroups();
  }

  @override
  Future<UserStoryGroupEntity?> fetchMyStories() async {
    try {
      final myStoryGroup = await _remoteDataSource.fetchMyStories();
      if (myStoryGroup != null) {
        final currentCached = List<UserStoryGroupEntity>.from(getStoryGroups());
        final idx = currentCached.indexWhere((g) => g.userId == 0 || g.userId == myStoryGroup.userId);
        if (idx != -1) {
          currentCached[idx] = myStoryGroup;
        } else {
          currentCached.insert(0, myStoryGroup);
        }
        await _saveGroups(currentCached);
        return myStoryGroup;
      }
    } catch (_) {}

    final cached = getStoryGroups();
    final idx = cached.indexWhere((g) => g.userId == 0);
    return idx != -1 ? cached[idx] : null;
  }

  @override
  Future<void> markStoryAsSeen(int userId, dynamic storyId) async {
    final currentGroups = List<UserStoryGroupEntity>.from(getStoryGroups());
    final groupIndex = currentGroups.indexWhere((g) => g.userId == userId);

    if (groupIndex != -1) {
      final group = currentGroups[groupIndex];
      final updatedStories = group.stories.map((s) {
        if (s.id.toString() == storyId.toString()) {
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

    try {
      await _remoteDataSource.markStoryViewed(storyId);
    } catch (_) {}
  }

  @override
  Future<void> addStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
  }) async {
    StoryItemEntity newStory;
    try {
      final uploadedModel = await _remoteDataSource.uploadStory(
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );
      newStory = uploadedModel;
    } catch (_) {
      newStory = StoryItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        createdAt: DateTime.now().toIso8601String(),
        isSeen: true,
      );
    }

    final currentGroups = List<UserStoryGroupEntity>.from(getStoryGroups());
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

  @override
  Future<List<StoryViewerEntity>> fetchStoryViewers(dynamic storyId, {int page = 0, int limit = 20}) async {
    try {
      return await _remoteDataSource.fetchViewers(storyId, page: page, limit: limit);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> fetchStoryViewCount(dynamic storyId) async {
    try {
      return await _remoteDataSource.fetchViewCount(storyId);
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> deleteStory(dynamic storyId) async {
    final currentGroups = getStoryGroups();
    bool deletedAny = false;

    for (int i = 0; i < currentGroups.length; i++) {
      final group = currentGroups[i];
      final originalLen = group.stories.length;
      final filtered = group.stories.where((s) => s.id.toString() != storyId.toString()).toList();
      if (filtered.length != originalLen) {
        deletedAny = true;
        currentGroups[i] = UserStoryGroupEntity(
          userId: group.userId,
          userName: group.userName,
          userImage: group.userImage,
          stories: filtered,
        );
      }
    }

    if (deletedAny) {
      final activeGroups = currentGroups.where((g) => g.activeStories.isNotEmpty).toList();
      await _saveGroups(activeGroups);
    }

    try {
      return await _remoteDataSource.deleteStory(storyId);
    } catch (_) {
      return deletedAny;
    }
  }

  @override
  Future<bool> toggleLikeStory(dynamic storyId, bool currentLikeState) async {
    final newLikeState = !currentLikeState;
    try {
      if (newLikeState) {
        await _remoteDataSource.likeStory(storyId);
      } else {
        await _remoteDataSource.unlikeStory(storyId);
      }
      return newLikeState;
    } catch (_) {
      return currentLikeState;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  Future<void> _saveGroups(List<UserStoryGroupEntity> groups) async {
    final models = groups.map((g) {
      return UserStoryGroupModel(
        userId: g.userId,
        userName: g.userName,
        userImage: g.userImage,
        stories: g.stories,
      );
    }).toList();

    await _localDataSource.saveStoryGroups(models);
  }
}
