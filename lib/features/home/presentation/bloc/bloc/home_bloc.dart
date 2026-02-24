import 'package:bloc/bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/features/chat/domain_usecase/get_chats_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetChatsUseCase _getChatsUseCase;
  HomeBloc({
    required GetChatsUseCase getchatsusecase,
  }) : _getChatsUseCase=getchatsusecase,
  super(const HomeState()) {
       on<_Init>(__Init);
  }
Future<void> __Init(_Init event, Emitter<HomeState> emit) async {
    emit(state.copyWith(homeChatsStatus: Status.loading));
  final chats = await _getChatsUseCase();

  final prefs = await SharedPreferences.getInstance();
  final idString = prefs.getString("id");

  if (idString == null) {
    emit(state.copyWith(homeChatsStatus: Status.error));
    return;
  }

  final myId = int.parse(idString);

  if (chats.isNotEmpty) {
    final users = buildConversationList(chats,myId);
    emit(state.copyWith(
      homeChatsStatus: Status.success,
      homePageChats: users,
    ));
  } else {
    emit(state.copyWith(homeChatsStatus: Status.error));
  }
}
List<HomeChatModel> buildConversationList(
  List<HomeChatModel> chats,
  int myId,
) {
  final Map<int, HomeChatModel> conversationMap = {};

  for (var chat in chats) {
    final otherUserId =
        chat.senderId == myId ? chat.receiverId : chat.senderId;

    if (!conversationMap.containsKey(otherUserId) ||
        chat.createdAt.isAfter(
            conversationMap[otherUserId]!.createdAt)) {
      conversationMap[otherUserId] = chat;
    }
  }

  final conversations = conversationMap.values.toList();

  conversations.sort(
    (a, b) => b.createdAt.compareTo(a.createdAt),
  );

  return conversations;
}
}
