class StoryModel {
  final String imageUrl;
  final String username;
  final bool isMyStory;

  StoryModel({
    required this.imageUrl,
    required this.username,
    required this.isMyStory,
  });

  factory StoryModel.empty() {
    return StoryModel(
      imageUrl: '',
      username: '',
      isMyStory: true,
    );
  }
}