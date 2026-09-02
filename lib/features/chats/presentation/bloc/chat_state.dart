import 'package:equatable/equatable.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';

enum ChatLoadedReason {
  initialFetch,
  messageSent,
  realtimeReceived,
  statusUpdated,
}

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final ChatLoadedReason reason;

  const ChatLoaded(
    this.messages, {
    this.reason = ChatLoadedReason.statusUpdated,
  });

  @override
  List<Object?> get props => [messages, reason];
}

class ChatError extends ChatState {
  final String message;
  final List<MessageEntity> previousMessages;

  const ChatError(this.message, {this.previousMessages = const []});

  @override
  List<Object?> get props => [message, previousMessages];
}
