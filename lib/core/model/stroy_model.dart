class StoryModel {
  final String username;
  final String imageUrl;
  final bool isMyStory;

  StoryModel({
    required this.username,
    required this.imageUrl,
    this.isMyStory = false,
  });
}