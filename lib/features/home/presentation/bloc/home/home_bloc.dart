import 'package:bloc/bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/features/home/domain_usecase/get_home_chats_list_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeChatsListUsecase _getHomeChatsListUseCase;
  HomeBloc({required GetHomeChatsListUsecase gethomechatslistusecase})
    : _getHomeChatsListUseCase = gethomechatslistusecase,
      super(const HomeState()) {
    on<_Init>(__Init);
  }

  Future<void> __Init(_Init event, Emitter<HomeState> emit) async {
    emit(state.copyWith(homeChatsStatus: Status.loading));

    try {
      
      final chats = await _getHomeChatsListUseCase();

      final prefs = await SharedPreferences.getInstance();
      final idString = prefs.getString("id");

      if (idString == null || idString.isEmpty) {
        emit(state.copyWith(homeChatsStatus: Status.error));
        return;
      }

      final myId = int.tryParse(idString);
      if (myId == null) {
        emit(state.copyWith(homeChatsStatus: Status.error));
        return;
      }

      if (chats.isEmpty) {
        emit(state.copyWith(homeChatsStatus: Status.error));
        return;
      }

      final users = buildConversationList(chats, myId);

      emit(
        state.copyWith(homeChatsStatus: Status.success, homePageChats: users),
      );
    } catch (e, stack) {
      print("🔥 ERROR: $e");
      print(stack);
      emit(state.copyWith(homeChatsStatus: Status.error));
    }
  }


List<HomeChatModel> buildConversationList(
  List<HomeChatModel> chats,
  int myId,
) {
  final Map<int, HomeChatModel> conversationMap = {};
  final Map<int, int> unreadCountMap = {};

  for (var chat in chats) {
    if (chat.message.isEmpty) continue;

    final otherUserId = chat.sender.id == myId
        ? chat.receiver.id
        : chat.sender.id;

    /// Count unread messages
    if (chat.receiver.id == myId && !chat.seen) {
      unreadCountMap[otherUserId] =
          (unreadCountMap[otherUserId] ?? 0) + 1;
    }

    /// Keep latest message
    if (!conversationMap.containsKey(otherUserId) ||
        chat.createdAt.isAfter(
          conversationMap[otherUserId]!.createdAt,
        )) {
      conversationMap[otherUserId] = chat;
    }
  }

  final conversations = conversationMap.values.map((chat) {
    final otherUserId = chat.sender.id == myId
        ? chat.receiver.id
        : chat.sender.id;

    return chat.copyWith(
      unSeenCount: unreadCountMap[otherUserId] ?? 0,
    );
  }).toList();

  /// Sort by latest message
  conversations.sort(
    (a, b) => b.createdAt.compareTo(a.createdAt),
  );

  return conversations;
}

}
