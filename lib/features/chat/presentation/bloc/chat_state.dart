part of 'chat_bloc.dart';

class ChatState {
  final Status SendMssgStatus;
  final Status GetMssgStatus;
  final Status DeleteMssgStatus;
  final List<ChatEntity> messages;

  const ChatState({
    this.SendMssgStatus = Status.init,
    this.GetMssgStatus = Status.init,
    this.DeleteMssgStatus = Status.init,
    this.messages = const [],
  });

  ChatState copyWith({
    Status? SendMssgStatus,
    Status? GetMssgStatus,
    Status? DeleteMssgStatus,
    List<ChatEntity>? messages,
  }) {
    return ChatState(
      SendMssgStatus: SendMssgStatus ?? this.SendMssgStatus,
      GetMssgStatus: GetMssgStatus ?? this.GetMssgStatus,
      DeleteMssgStatus: DeleteMssgStatus ?? this.DeleteMssgStatus,
      messages: messages ?? this.messages,
    );
  }
}
