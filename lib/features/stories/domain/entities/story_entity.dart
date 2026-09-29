class StoryViewerEntity {
  final int userId;
  final String userName;
  final String userProfileImage;
  final String viewedAt;
  final bool hasLiked;

  const StoryViewerEntity({
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.viewedAt,
    this.hasLiked = false,
  });

  // Backward-compatible getters
  int get viewerId => userId;
  String get viewerName => userName;
  String get viewerImage => userProfileImage;
}

class StoryItemEntity {
  final String id;
  final String mediaUrl;
  final String mediaType; // 'IMAGE' or 'VIDEO'
  final int durationSeconds;
  final String createdAt;
  final bool isSeen;
  final int viewCount;
  final int likeCount;
  final bool hasLiked;
  final List<StoryViewerEntity> viewers;

  const StoryItemEntity({
    required this.id,
    required this.mediaUrl,
    this.mediaType = 'IMAGE',
    this.durationSeconds = 5,
    required this.createdAt,
    this.isSeen = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.hasLiked = false,
    this.viewers = const [],
  });

  bool get isExpired {
    try {
      final created = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      return now.difference(created).inHours >= 24;
    } catch (_) {
      return false;
    }
  }

  StoryItemEntity copyWith({
    bool? isSeen,
    int? viewCount,
    int? likeCount,
    bool? hasLiked,
    List<StoryViewerEntity>? viewers,
  }) {
    return StoryItemEntity(
      id: id,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      durationSeconds: durationSeconds,
      createdAt: createdAt,
      isSeen: isSeen ?? this.isSeen,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      hasLiked: hasLiked ?? this.hasLiked,
      viewers: viewers ?? this.viewers,
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
