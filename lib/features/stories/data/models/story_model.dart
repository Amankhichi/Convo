import 'package:convo/features/stories/domain/entities/story_entity.dart';

class StoryItemModel extends StoryItemEntity {
  const StoryItemModel({
    required super.id,
    required super.mediaUrl,
    super.mediaType = 'IMAGE',
    super.durationSeconds = 5,
    required super.createdAt,
    super.isSeen = false,
  });

  factory StoryItemModel.fromJson(Map<String, dynamic> json) {
    return StoryItemModel(
      id: json['id']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'IMAGE',
      durationSeconds: json['durationSeconds'] is int
          ? json['durationSeconds']
          : int.tryParse(json['durationSeconds']?.toString() ?? '5') ?? 5,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      isSeen: json['isSeen'] == true,
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
      userName: json['userName']?.toString() ?? '',
      userImage: json['userImage']?.toString() ?? '',
      stories: storiesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'stories': stories
          .map((s) => (s is StoryItemModel ? s : StoryItemModel(
                id: s.id,
                mediaUrl: s.mediaUrl,
                mediaType: s.mediaType,
                durationSeconds: s.durationSeconds,
                createdAt: s.createdAt,
                isSeen: s.isSeen,
              )).toJson())
          .toList(),
    };
  }
}
