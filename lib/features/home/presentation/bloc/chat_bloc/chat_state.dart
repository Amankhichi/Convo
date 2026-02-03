part of 'chat_bloc.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
@Default(Status.init) Status contactStatus,
    @Default([]) List<UserModel> contacts,
  }) = _ChatState;
}
