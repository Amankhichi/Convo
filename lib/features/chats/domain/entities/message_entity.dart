import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
  failed,
}

extension MessageStatusX on MessageStatus {
  int get rank {
    switch (this) {
      case MessageStatus.failed:
        return -1;
      case MessageStatus.sending:
        return 0;
      case MessageStatus.sent:
        return 1;
      case MessageStatus.delivered:
        return 2;
      case MessageStatus.seen:
        return 3;
    }
  }

  String toStatusString() {
    switch (this) {
      case MessageStatus.sending:
        return 'SENDING';
      case MessageStatus.sent:
        return 'SENT';
      case MessageStatus.delivered:
        return 'DELIVERED';
      case MessageStatus.seen:
        return 'SEEN';
      case MessageStatus.failed:
        return 'FAILED';
    }
  }
}

class MessageEntity {
  final int id;
  final String? clientMessageId;
  final int chatId;
  final int senderId;
  final int? receiverId;
  final String type;
  final String content;
  final String? mediaUrl;
  final String status; // "SENDING", "SENT", "DELIVERED", "SEEN", "FAILED"
  final String createdAt;
  final bool seen;
  final bool edited;
  final int? replyToId;
  final String? replyToContent;
  final StoryReplyEntity? storyReply;
  final String? deliveredAt;
  final String? seenAt;

  const MessageEntity({
    required this.id,
    this.clientMessageId,
    required this.chatId,
    required this.senderId,
    this.receiverId,
    required this.type,
    required this.content,
    this.mediaUrl,
    required this.status,
    required this.createdAt,
    required this.seen,
    this.edited = false,
    this.replyToId,
    this.replyToContent,
    this.storyReply,
    this.deliveredAt,
    this.seenAt,
  });

  MessageStatus get messageStatus {
    final s = status.toUpperCase();
    if (s == 'PENDING' || s == 'SENDING' || s == 'UPLOADING') return MessageStatus.sending;
    if (s == 'SENT') return MessageStatus.sent;
    if (s == 'DELIVERED') return MessageStatus.delivered;
    if (s == 'SEEN' || seen) return MessageStatus.seen;
    if (s == 'FAILED') return MessageStatus.failed;
    return MessageStatus.sent;
  }

  bool get isUploading => status.toUpperCase() == 'UPLOADING';
  bool get isFailed => status.toUpperCase() == 'FAILED';

  bool canTransitionTo(MessageStatus newStatus) {
    if (newStatus == MessageStatus.sending && messageStatus == MessageStatus.failed) {
      return true; // Allowed on retry
    }
    return newStatus.rank > messageStatus.rank;
  }
}
