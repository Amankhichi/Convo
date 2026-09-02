class StoryItemEntity {
  final String id;
  final String mediaUrl;
  final String mediaType; // 'IMAGE' or 'VIDEO'
  final int durationSeconds;
  final String createdAt;
  final bool isSeen;

  const StoryItemEntity({
    required this.id,
    required this.mediaUrl,
    this.mediaType = 'IMAGE',
    this.durationSeconds = 5,
    required this.createdAt,
    this.isSeen = false,
  });

  bool get isExpired {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      return now.difference(created).inHours >= 24;
    } catch (_) {
      return false;
    }
  }

  StoryItemEntity copyWith({bool? isSeen}) {
    return StoryItemEntity(
      id: id,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      durationSeconds: durationSeconds,
      createdAt: createdAt,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}

class UserStoryGroupEntity {
  final int userId;
  final String userName;
  final String userImage;
  final List<StoryItemEntity> stories;

  const UserStoryGroupEntity({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.stories,
  });

  bool get hasUnseenStories {
    return stories.any((s) => !s.isSeen && !s.isExpired);
  }

  List<StoryItemEntity> get activeStories {
    return stories.where((s) => !s.isExpired).toList();
  }
}
