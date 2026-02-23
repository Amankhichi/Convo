part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
 const factory HomeState({
    @Default(Status.init) Status homeChatsStatus,
    @Default([]) List<HomeChatModel> homePageChats,
  }) = _HomeState;
}
