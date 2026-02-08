part of 'chat_bloc.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<UserModel> contacts,
@Default(Status.init) Status contactStatus,
@Default(Status.init) Status SendMssgStatus,
@Default(Status.init) Status GetMssgStatus,
  @Default([]) List<ChatModel> messages,

  }) = _ChatState;
}
