import 'package:convo/features/stories/domain/entities/story_entity.dart';

abstract class StoryRepository {
  List<UserStoryGroupEntity> getStoryGroups();
  Future<void> markStoryAsSeen(int userId, String storyId);
  Future<void> addStory({required String mediaUrl, String mediaType = 'IMAGE'});
}
