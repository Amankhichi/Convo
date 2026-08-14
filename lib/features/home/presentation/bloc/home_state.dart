part of 'home_bloc.dart';

class HomeState {
  final Status homeChatsStatus;
  final List<HomeChatModel> homePageChats;

  const HomeState({
    this.homeChatsStatus = Status.init,
    this.homePageChats = const [],
  });

  HomeState copyWith({
    Status? homeChatsStatus,
    List<HomeChatModel>? homePageChats,
  }) {
    return HomeState(
      homeChatsStatus: homeChatsStatus ?? this.homeChatsStatus,
      homePageChats: homePageChats ?? this.homePageChats,
    );
  }
}
