import 'package:convo/features/stories/domain/entities/story_entity.dart';

class StoryViewerModel extends StoryViewerEntity {
  const StoryViewerModel({
    required super.userId,
    required super.userName,
    required super.userProfileImage,
    required super.viewedAt,
    super.hasLiked = false,
  });

  factory StoryViewerModel.fromJson(Map<String, dynamic> json) {
    final parsedUserId = json['userId'] is int
        ? json['userId']
        : (json['viewerId'] is int
            ? json['viewerId']
            : int.tryParse(json['userId']?.toString() ?? json['viewerId']?.toString() ?? '0') ?? 0);

    final parsedName = json['userName']?.toString() ??
        json['viewerName']?.toString() ??
        json['username']?.toString() ??
        json['name']?.toString() ??
        'ConVo User';

    final parsedImage = json['userProfileImage']?.toString() ??
        json['viewerImage']?.toString() ??
        json['profileImage']?.toString() ??
        json['image']?.toString() ??
        '';

    final parsedViewedAt = json['viewedAt']?.toString() ??
        json['createdAt']?.toString() ??
        '';

    final parsedHasLiked = json['hasLiked'] == true || json['liked'] == true;

    return StoryViewerModel(
      userId: parsedUserId,
      userName: parsedName,
      userProfileImage: parsedImage,
      viewedAt: parsedViewedAt,
      hasLiked: parsedHasLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'viewerId': userId,
      'userName': userName,
      'viewerName': userName,
      'userProfileImage': userProfileImage,
      'viewerImage': userProfileImage,
      'viewedAt': viewedAt,
      'hasLiked': hasLiked,
    };
  }
}

class StoryItemModel extends StoryItemEntity {
  const StoryItemModel({
    required super.id,
    required super.mediaUrl,
    super.mediaType = 'IMAGE',
    super.durationSeconds = 5,
    required super.createdAt,
    super.isSeen = false,
    super.viewCount = 0,
    super.likeCount = 0,
    super.hasLiked = false,
    super.viewers = const [],
  });

  factory StoryItemModel.fromJson(Map<String, dynamic> json) {
    final rawViewers = json['viewers'];
    List<StoryViewerModel> viewerList = [];
    if (rawViewers is List) {
      viewerList = rawViewers
          .map((v) => StoryViewerModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return StoryItemModel(
      id: json['id']?.toString() ?? json['storyId']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? json['url']?.toString() ?? '',
      mediaType: json['mediaType']?.toString().toUpperCase() ?? 'IMAGE',
      durationSeconds: json['durationSeconds'] is int
          ? json['durationSeconds']
          : int.tryParse(json['durationSeconds']?.toString() ?? '5') ?? 5,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      isSeen: json['isSeen'] == true || json['hasViewed'] == true,
      viewCount: json['viewCount'] is int
          ? json['viewCount']
          : int.tryParse(json['viewCount']?.toString() ?? '0') ?? 0,
      likeCount: json['likeCount'] is int
          ? json['likeCount']
          : int.tryParse(json['likeCount']?.toString() ?? '0') ?? 0,
      hasLiked: json['hasLiked'] == true || json['liked'] == true,
      viewers: viewerList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt,
      'isSeen': isSeen,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'hasLiked': hasLiked,
      'viewers': viewers
          .map((v) => (v is StoryViewerModel
                  ? v
                  : StoryViewerModel(
                      userId: v.userId,
                      userName: v.userName,
                      userProfileImage: v.userProfileImage,
                      viewedAt: v.viewedAt,
                      hasLiked: v.hasLiked,
                    ))
              .toJson())
          .toList(),
    };
  }
}

class UserStoryGroupModel extends UserStoryGroupEntity {
  const UserStoryGroupModel({
    required super.userId,
    required super.userName,
    required super.userImage,
    required super.stories,
  });

  factory UserStoryGroupModel.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List?)
            ?.map((s) => StoryItemModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return UserStoryGroupModel(
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userName: json['userName']?.toString() ?? json['username']?.toString() ?? '',
      userImage: json['userImage']?.toString() ?? json['profileImage']?.toString() ?? '',
      stories: storiesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'stories': stories
          .map((s) => (s is StoryItemModel
                  ? s
                  : StoryItemModel(
                      id: s.id,
                      mediaUrl: s.mediaUrl,
                      mediaType: s.mediaType,
                      durationSeconds: s.durationSeconds,
                      createdAt: s.createdAt,
                      isSeen: s.isSeen,
                      viewCount: s.viewCount,
                      likeCount: s.likeCount,
                      hasLiked: s.hasLiked,
                      viewers: s.viewers,
                    ))
              .toJson())
          .toList(),
    };
  }
}
