import 'package:convo/features/stories/domain/entities/story_entity.dart';

abstract class StoryRepository {
  List<UserStoryGroupEntity> getStoryGroups();
  Future<List<UserStoryGroupEntity>> fetchStoryFeed({int page = 0, int limit = 20});
  Future<UserStoryGroupEntity?> fetchMyStories();
  Future<void> markStoryAsSeen(int userId, dynamic storyId);
  Future<void> addStory({required String mediaUrl, String mediaType = 'IMAGE'});
  Future<List<StoryViewerEntity>> fetchStoryViewers(dynamic storyId, {int page = 0, int limit = 20});
  Future<int> fetchStoryViewCount(dynamic storyId);
  Future<bool> deleteStory(dynamic storyId);
  Future<bool> toggleLikeStory(dynamic storyId, bool currentLikeState);
  Future<void> clearCache();
}
