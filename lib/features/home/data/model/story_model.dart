class StoryModel {
  final String imageUrl;
  final String username;
  final bool isMyStory;

  const StoryModel({
    required this.imageUrl,
    required this.username,
    required this.isMyStory,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      imageUrl: json['imageUrl'] ?? '',
      username: json['username'] ?? '',
      isMyStory: json['isMyStory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'imageUrl': imageUrl, 'username': username, 'isMyStory': isMyStory};
  }

  StoryModel copyWith({String? imageUrl, String? username, bool? isMyStory}) {
    return StoryModel(
      imageUrl: imageUrl ?? this.imageUrl,
      username: username ?? this.username,
      isMyStory: isMyStory ?? this.isMyStory,
    );
  }

  factory StoryModel.empty() {
    return const StoryModel(imageUrl: '', username: '', isMyStory: false);
  }
}
