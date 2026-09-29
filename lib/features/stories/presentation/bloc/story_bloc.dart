import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/network/stomp_service.dart';
import 'package:convo/features/stories/data/models/story_model.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/features/stories/presentation/bloc/story_event.dart';
import 'package:convo/features/stories/presentation/bloc/story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository _storyRepository;
  final StompService _stompService;
  StreamSubscription? _stompSubscription;

  StoryBloc({
    required StoryRepository storyRepository,
    required StompService stompService,
  })  : _storyRepository = storyRepository,
        _stompService = stompService,
        super(StoryInitial()) {
    on<FetchStoryFeedEvent>(_onFetchFeed);
    on<FetchMyStoriesEvent>(_onFetchMyStories);
    on<UploadStoryEvent>(_onUploadStory);
    on<ViewStoryEvent>(_onViewStory);
    on<FetchStoryViewersEvent>(_onFetchViewers);
    on<DeleteStoryEvent>(_onDeleteStory);
    on<ToggleLikeStoryEvent>(_onToggleLikeStory);
    on<RealtimeStoryViewedEvent>(_onRealtimeStoryViewed);

    _listenStompEvents();
  }

  void _listenStompEvents() {
    _stompSubscription = _stompService.messageEvents.listen((data) {
      final type = data['type']?.toString().toUpperCase() ?? '';
      if (type == 'STORY_CREATED' || type == 'STORY_DELETED' || type == 'STORY_UPDATED') {
        add(const FetchStoryFeedEvent());
      } else if (type == 'STORY_VIEWED') {
        add(RealtimeStoryViewedEvent(data));
      }
    });
  }

  Future<void> _onFetchFeed(
    FetchStoryFeedEvent event,
    Emitter<StoryState> emit,
  ) async {
    final cached = List<UserStoryGroupEntity>.from(_storyRepository.getStoryGroups());
    UserStoryGroupEntity? myGroupCached;
    try {
      myGroupCached = await _storyRepository.fetchMyStories();
    } catch (_) {}

    final initialMyGroup = myGroupCached ?? cached.firstWhere(
      (g) => g.userId == 0,
      orElse: () => const UserStoryGroupEntity(userId: 0, userName: "My Story", userImage: "", stories: []),
    );

    if (cached.isNotEmpty || initialMyGroup.stories.isNotEmpty) {
      emit(StoryFeedLoaded(
        storyGroups: cached,
        myStories: initialMyGroup.stories.isNotEmpty ? initialMyGroup : null,
      ));
    } else {
      emit(StoryLoading());
    }

    try {
      final groups = await _storyRepository.fetchStoryFeed(page: event.page, limit: event.limit);
      final remoteMyGroup = await _storyRepository.fetchMyStories();
      final finalMyGroup = remoteMyGroup ?? groups.firstWhere(
        (g) => g.userId == 0,
        orElse: () => const UserStoryGroupEntity(userId: 0, userName: "My Story", userImage: "", stories: []),
      );

      emit(StoryFeedLoaded(
        storyGroups: groups,
        myStories: finalMyGroup.stories.isNotEmpty ? finalMyGroup : null,
      ));
    } catch (e) {
      if (cached.isNotEmpty || initialMyGroup.stories.isNotEmpty) {
        emit(StoryFeedLoaded(
          storyGroups: cached,
          myStories: initialMyGroup.stories.isNotEmpty ? initialMyGroup : null,
        ));
      } else {
        emit(StoryError(e.toString()));
      }
    }
  }

  Future<void> _onFetchMyStories(
    FetchMyStoriesEvent event,
    Emitter<StoryState> emit,
  ) async {
    try {
      final myStoriesGroup = await _storyRepository.fetchMyStories();
      final currentGroups = _storyRepository.getStoryGroups();
      emit(StoryFeedLoaded(storyGroups: currentGroups, myStories: myStoriesGroup));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onUploadStory(
    UploadStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(const StoryUploadingState(progress: 0.1));
    try {
      await _storyRepository.addStory(
        mediaUrl: event.mediaUrl,
        mediaType: event.mediaType,
      );
      emit(const StoryUploadingState(progress: 1.0));
      emit(StoryUploadedSuccess());
      add(const FetchStoryFeedEvent());
    } catch (e) {
      emit(StoryError("Failed to upload story: ${e.toString()}"));
    }
  }

  Future<void> _onViewStory(
    ViewStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    await _storyRepository.markStoryAsSeen(event.userId, event.storyId);
  }

  Future<void> _onFetchViewers(
    FetchStoryViewersEvent event,
    Emitter<StoryState> emit,
  ) async {
    try {
      final count = await _storyRepository.fetchStoryViewCount(event.storyId);
      final viewers = await _storyRepository.fetchStoryViewers(
        event.storyId,
        page: event.page,
        limit: event.limit,
      );

      if (state is StoryViewersLoaded && event.page > 0) {
        final current = state as StoryViewersLoaded;
        if (current.storyId.toString() == event.storyId.toString()) {
          // Append new page and deduplicate by viewer.userId
          final existingIds = current.viewers.map((v) => v.userId).toSet();
          final filteredNew = viewers.where((v) => !existingIds.contains(v.userId)).toList();
          emit(StoryViewersLoaded(
            storyId: event.storyId,
            viewCount: count > 0 ? count : current.viewCount,
            viewers: [...current.viewers, ...filteredNew],
          ));
          return;
        }
      }

      emit(StoryViewersLoaded(storyId: event.storyId, viewCount: count, viewers: viewers));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onDeleteStory(
    DeleteStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    try {
      final success = await _storyRepository.deleteStory(event.storyId);
      if (success) {
        emit(StoryDeletedSuccess(event.storyId));
        add(const FetchStoryFeedEvent());
      } else {
        emit(const StoryError("Failed to delete story."));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onToggleLikeStory(
    ToggleLikeStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    await _storyRepository.toggleLikeStory(event.storyId, event.currentLikeState);
  }

  void _onRealtimeStoryViewed(
    RealtimeStoryViewedEvent event,
    Emitter<StoryState> emit,
  ) {
    if (state is StoryViewersLoaded) {
      final current = state as StoryViewersLoaded;
      final data = event.data;
      final targetStoryId = data['storyId']?.toString();

      if (targetStoryId != null && targetStoryId == current.storyId.toString()) {
        final newCount = data['viewCount'] is int
            ? data['viewCount'] as int
            : (int.tryParse(data['viewCount']?.toString() ?? '0') ?? current.viewCount + 1);

        List<StoryViewerEntity> currentViewers = List.from(current.viewers);
        if (data['viewer'] is Map<String, dynamic>) {
          final newViewer = StoryViewerModel.fromJson(data['viewer'] as Map<String, dynamic>);
          if (newViewer.userId > 0) {
            // Deduplicate strictly using storyId + viewer.userId
            currentViewers.removeWhere((v) => v.userId == newViewer.userId);
            currentViewers.insert(0, newViewer);
          }
        }

        emit(StoryViewersLoaded(
          storyId: current.storyId,
          viewCount: newCount,
          viewers: currentViewers,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _stompSubscription?.cancel();
    return super.close();
  }
}
