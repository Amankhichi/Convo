import 'package:equatable/equatable.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchMessagesEvent extends ChatEvent {
  final int chatId;

  const FetchMessagesEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessageEvent extends ChatEvent {
  final int chatId;
  final int receiverId;
  final String content;
  final String type;
  final String? mediaUrl;
  final String? clientMessageId;
  final int? replyToId;
  final StoryReplyEntity? storyReply;

  const SendMessageEvent({
    required this.chatId,
    required this.receiverId,
    required this.content,
    this.type = "TEXT",
    this.mediaUrl,
    this.clientMessageId,
    this.replyToId,
    this.storyReply,
  });

  @override
  List<Object?> get props => [chatId, receiverId, content, type, mediaUrl, clientMessageId, replyToId, storyReply];
}

class SendMediaMessageEvent extends ChatEvent {
  final int chatId;
  final int receiverId;
  final String filePath;
  final String type;
  final String content;
  final String? clientMessageId;
  final int? replyToId;

  const SendMediaMessageEvent({
    required this.chatId,
    required this.receiverId,
    required this.filePath,
    required this.type,
    required this.content,
    this.clientMessageId,
    this.replyToId,
  });

  @override
  List<Object?> get props => [chatId, receiverId, filePath, type, content, clientMessageId, replyToId];
}

class RetrySendMessageEvent extends ChatEvent {
  final MessageEntity message;

  const RetrySendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkMessagesSeenEvent extends ChatEvent {
  final int chatId;

  const MarkMessagesSeenEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class RealtimeMessageReceivedEvent extends ChatEvent {
  final MessageEntity message;

  const RealtimeMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class RealtimeStatusUpdatedEvent extends ChatEvent {
  final Map<String, dynamic> statusData;

  const RealtimeStatusUpdatedEvent(this.statusData);

  @override
  List<Object?> get props => [statusData];
}

class EditMessageEvent extends ChatEvent {
  final int messageId;
  final String newContent;

  const EditMessageEvent({
    required this.messageId,
    required this.newContent,
  });

  @override
  List<Object?> get props => [messageId, newContent];
}

class DeleteMessageEvent extends ChatEvent {
  final int messageId;

  const DeleteMessageEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
