import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/network/chat_realtime_service.dart';
import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';
import 'package:convo/features/home/domain/repositories/home_repository.dart';
import 'package:convo/features/home/presentation/bloc/home_event.dart';
import 'package:convo/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final ChatRealtimeService _realtimeService;
  StreamSubscription? _realtimeSub;
  Timer? _pollTimer;

  HomeBloc({
    required HomeRepository homeRepository,
    required ChatRealtimeService realtimeService,
  }) : _homeRepository = homeRepository,
       _realtimeService = realtimeService,
       super(HomeInitial()) {
    on<FetchHomeChatsEvent>(_onFetchHomeChats);
    on<RealtimeHomeMessageReceivedEvent>(_onRealtimeHomeMessageReceived);

    _listenRealtimeEvents();
    _startPeriodicPolling();
  }

  void _startPeriodicPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(FetchHomeChatsEvent());
    });
  }

  void _listenRealtimeEvents() {
    _realtimeSub = _realtimeService.newMessageStream.listen((msg) {
      add(RealtimeHomeMessageReceivedEvent(msg));
    });
  }

  List<ChatSummaryEntity> _filterAndSort(List<ChatSummaryEntity> chats) {
    final filtered = chats.where((c) {
      if (c.chatType == 'SYSTEM') return false;
      return c.lastMessageContent.trim().isNotEmpty ||
          c.lastMessageTime.trim().isNotEmpty;
    }).toList();

    filtered.sort((a, b) {
      if (a.lastMessageTime.isEmpty) return 1;
      if (b.lastMessageTime.isEmpty) return -1;
      try {
        final dtA = DateTime.parse(a.lastMessageTime);
        final dtB = DateTime.parse(b.lastMessageTime);
        return dtB.compareTo(dtA);
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }

  Future<void> _onFetchHomeChats(
    FetchHomeChatsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final cached = _homeRepository.getCachedChats();
    final filteredCached = _filterAndSort(cached);

    if (state is! HomeLoaded) {
      if (filteredCached.isNotEmpty) {
        emit(HomeLoaded(filteredCached));
      } else {
        emit(HomeLoading());
      }
    }

    try {
      final remoteChats = await _homeRepository.fetchChats();
      final filteredRemote = _filterAndSort(remoteChats);
      emit(HomeLoaded(filteredRemote));
    } catch (e) {
      if (state is! HomeLoaded) {
        if (filteredCached.isNotEmpty) {
          emit(HomeLoaded(filteredCached));
        } else {
          emit(HomeError(e.toString()));
        }
      }
    }
  }

  void _onRealtimeHomeMessageReceived(
    RealtimeHomeMessageReceivedEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentList = List<ChatSummaryEntity>.from(
        (state as HomeLoaded).chats,
      );
      final msg = event.message;

      final index = currentList.indexWhere((c) => c.chatId == msg.chatId);
      if (index != -1) {
        final existing = currentList[index];

        if (msg.content.trim().isEmpty) {
          currentList.removeAt(index);
          emit(HomeLoaded(_filterAndSort(currentList)));
          return;
        }

        final isIncoming = msg.senderId == existing.targetUserId;
        final isOutgoing = !isIncoming;

        String formattedContent = msg.content;
        if (isOutgoing && !formattedContent.startsWith("You: ")) {
          formattedContent = "You: $formattedContent";
        }

        final updatedChat = ChatSummaryEntity(
          chatId: existing.chatId,
          chatType: existing.chatType,
          targetUserId: existing.targetUserId,
          targetUserName: existing.targetUserName,
          targetUserImage: existing.targetUserImage,
          targetUserAbout: existing.targetUserAbout,
          targetUserPhone: existing.targetUserPhone,
          lastMessageContent: formattedContent,
          lastMessageTime: msg.createdAt,
          unreadCount: isIncoming ? existing.unreadCount + 1 : 0,
          online: existing.online,
        );

        currentList.removeAt(index);
        currentList.insert(0, updatedChat);

        emit(HomeLoaded(_filterAndSort(currentList)));
      } else {
        add(FetchHomeChatsEvent());
      }
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _realtimeSub?.cancel();
    return super.close();
  }
}
