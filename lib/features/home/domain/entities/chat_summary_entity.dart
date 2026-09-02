class ChatSummaryEntity {
  final int chatId;
  final String chatType;
  final int targetUserId;
  final String targetUserName;
  final String targetUserImage;
  final String targetUserAbout;
  final String targetUserPhone;
  final String lastMessageContent;
  final String lastMessageTime;
  final int unreadCount;
  final bool online;

  const ChatSummaryEntity({
    required this.chatId,
    required this.chatType,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserImage,
    required this.targetUserAbout,
    required this.targetUserPhone,
    required this.lastMessageContent,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.online,
  });
}
