import 'package:convo/app/config/api_config.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    super.clientMessageId,
    required super.chatId,
    required super.senderId,
    super.receiverId,
    required super.type,
    required super.content,
    super.mediaUrl,
    required super.status,
    required super.createdAt,
    required super.seen,
    super.edited = false,
    super.replyToId,
    super.replyToContent,
    super.storyReply,
    super.deliveredAt,
    super.seenAt,
  });

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      clientMessageId: entity.clientMessageId,
      chatId: entity.chatId,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      type: entity.type,
      content: entity.content,
      mediaUrl: entity.mediaUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      seen: entity.seen,
      edited: entity.edited,
      replyToId: entity.replyToId,
      replyToContent: entity.replyToContent,
      storyReply: entity.storyReply,
      deliveredAt: entity.deliveredAt,
      seenAt: entity.seenAt,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toUpperCase() ?? 'SENT';
    final isSeen = json['seen'] == true || statusStr == 'SEEN';
    final isEdited = json['edited'] == true;
    String? rawMedia;
    if (json['mediaUrl'] != null && json['mediaUrl'].toString().isNotEmpty) {
      rawMedia = json['mediaUrl'].toString();
    } else if (json['media'] != null) {
      if (json['media'] is Map<String, dynamic>) {
        final map = json['media'] as Map<String, dynamic>;
        rawMedia = map['fileUrl']?.toString() ?? map['url']?.toString() ?? map['path']?.toString();
      } else {
        rawMedia = json['media'].toString();
      }
    }

    if ((rawMedia == null || rawMedia.isEmpty) && json['content'] != null) {
      final contentStr = json['content'].toString();
      if (contentStr.startsWith('http://') ||
          contentStr.startsWith('https://') ||
          contentStr.startsWith('/uploads') ||
          contentStr.startsWith('file://')) {
        rawMedia = contentStr;
      }
    }

    final rId = json['replyToId'] is int
        ? json['replyToId']
        : int.tryParse(json['replyToId']?.toString() ?? '0');

    // Parse storyReply metadata
    StoryReplyEntity? parsedStoryReply;
    if (json['storyReply'] != null && json['storyReply'] is Map<String, dynamic>) {
      parsedStoryReply = StoryReplyEntity.fromJson(json['storyReply'] as Map<String, dynamic>);
    } else if (json['story_reply'] != null && json['story_reply'] is Map<String, dynamic>) {
      parsedStoryReply = StoryReplyEntity.fromJson(json['story_reply'] as Map<String, dynamic>);
    } else if (json['type']?.toString().toUpperCase() == 'STORY_REPLY' && json['storyId'] != null) {
      parsedStoryReply = StoryReplyEntity(
        storyId: json['storyId'].toString(),
        mediaUrl: json['storyMediaUrl']?.toString() ?? rawMedia ?? '',
        mediaType: json['storyMediaType']?.toString().toUpperCase() ?? 'IMAGE',
        createdAt: json['storyCreatedAt']?.toString(),
        isExpired: json['isExpired'] == true,
      );
    }

    return MessageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      clientMessageId: json['clientMessageId']?.toString(),
      chatId: json['chatId'] is int
          ? json['chatId']
          : int.tryParse(json['chatId']?.toString() ?? '0') ?? 0,
      senderId: json['senderId'] is int
          ? json['senderId']
          : int.tryParse(json['senderId']?.toString() ?? '0') ?? 0,
      receiverId: json['receiverId'] is int
          ? json['receiverId']
          : int.tryParse(json['receiverId']?.toString() ?? '0'),
      type: json['type']?.toString() ?? (parsedStoryReply != null ? 'STORY_REPLY' : 'TEXT'),
      content:
          json['content']?.toString() ??
          json['message']?.toString() ??
          json['mssg']?.toString() ??
          '',
      mediaUrl: ApiConfig.sanitizeUrl(rawMedia),
      status: statusStr,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      seen: isSeen,
      edited: isEdited,
      replyToId: (rId != null && rId > 0) ? rId : null,
      replyToContent: json['replyToContent']?.toString(),
      storyReply: parsedStoryReply,
      deliveredAt: json['deliveredAt']?.toString(),
      seenAt: json['seenAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientMessageId': clientMessageId,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'status': status,
      'createdAt': createdAt,
      'seen': seen,
      'edited': edited,
      'replyToId': replyToId,
      'replyToContent': replyToContent,
      'storyReply': storyReply?.toJson(),
      'deliveredAt': deliveredAt,
      'seenAt': seenAt,
    };
  }
}
