import 'package:convo/app/config/api_config.dart';
import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';

class ChatSummaryModel extends ChatSummaryEntity {
  const ChatSummaryModel({
    required super.chatId,
    required super.chatType,
    required super.targetUserId,
    required super.targetUserName,
    required super.targetUserImage,
    required super.targetUserAbout,
    required super.targetUserPhone,
    required super.lastMessageContent,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.online,
  });

  factory ChatSummaryModel.fromJson(Map<String, dynamic> json) {
    final otherUser = json['otherUser'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>?;

    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;

    final String name = json['targetUserName']?.toString() ??
        otherUser?['name']?.toString() ??
        otherUser?['username']?.toString() ??
        'ConVo User';

    final String rawImage = json['targetUserImage']?.toString() ??
        otherUser?['profileImage']?.toString() ??
        otherUser?['profile']?.toString() ??
        otherUser?['avatar']?.toString() ??
        '';
    final String image = ApiConfig.sanitizeUrl(rawImage);

    final String about = json['targetUserAbout']?.toString() ??
        otherUser?['about']?.toString() ??
        '';

    final String phone = json['targetUserPhone']?.toString() ??
        otherUser?['phoneNumber']?.toString() ??
        otherUser?['phone']?.toString() ??
        '';

    final int userId = json['targetUserId'] is int
        ? json['targetUserId']
        : int.tryParse(json['targetUserId']?.toString() ?? '') ??
            (otherUser?['id'] is int
                ? otherUser!['id']
                : int.tryParse(otherUser?['id']?.toString() ?? '0') ?? 0);

    String rawContent = json['lastMessageContent']?.toString() ??
        lastMsg?['content']?.toString() ??
        lastMsg?['message']?.toString() ??
        lastMsg?['mssg']?.toString() ??
        '';

    final lastMsgSenderId = lastMsg?['senderId'] is int
        ? lastMsg!['senderId']
        : int.tryParse(lastMsg?['senderId']?.toString() ?? '0') ?? 0;

    final isOutgoing = (lastMsgSenderId != 0 && lastMsgSenderId != userId) ||
        (json['lastMessageSenderId'] != null && json['lastMessageSenderId'] != userId);

    if (isOutgoing && rawContent.isNotEmpty && !rawContent.startsWith("You: ")) {
      rawContent = "You: $rawContent";
    }

    final rawUnread = json['unreadCount'] is int
        ? json['unreadCount']
        : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0;

    final effectiveUnread = isOutgoing ? 0 : rawUnread;

    return ChatSummaryModel(
      chatId: json['chatId'] is int
          ? json['chatId']
          : int.tryParse(json['chatId']?.toString() ?? '0') ?? 0,
      chatType: json['chatType']?.toString() ?? 'DIRECT',
      targetUserId: userId,
      targetUserName: name,
      targetUserImage: image,
      targetUserAbout: about,
      targetUserPhone: phone,
      lastMessageContent: rawContent,
      lastMessageTime: json['lastMessageTime']?.toString() ??
          lastMsg?['createdAt']?.toString() ??
          '',
      unreadCount: effectiveUnread,
      online: json['online'] == true || otherUser?['online'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'chatType': chatType,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetUserImage': targetUserImage,
      'targetUserAbout': targetUserAbout,
      'targetUserPhone': targetUserPhone,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'online': online,
    };
  }
}
