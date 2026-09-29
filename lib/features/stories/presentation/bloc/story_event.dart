import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchStoryFeedEvent extends StoryEvent {
  final int page;
  final int limit;

  const FetchStoryFeedEvent({this.page = 0, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class FetchMyStoriesEvent extends StoryEvent {}

class UploadStoryEvent extends StoryEvent {
  final String mediaUrl;
  final String mediaType; // 'IMAGE' or 'VIDEO'

  const UploadStoryEvent({
    required this.mediaUrl,
    this.mediaType = 'IMAGE',
  });

  @override
  List<Object?> get props => [mediaUrl, mediaType];
}

class ViewStoryEvent extends StoryEvent {
  final int userId;
  final dynamic storyId;

  const ViewStoryEvent({required this.userId, required this.storyId});

  @override
  List<Object?> get props => [userId, storyId];
}

class FetchStoryViewersEvent extends StoryEvent {
  final dynamic storyId;
  final int page;
  final int limit;

  const FetchStoryViewersEvent(this.storyId, {this.page = 0, this.limit = 20});

  @override
  List<Object?> get props => [storyId, page, limit];
}

class DeleteStoryEvent extends StoryEvent {
  final dynamic storyId;

  const DeleteStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class ToggleLikeStoryEvent extends StoryEvent {
  final dynamic storyId;
  final bool currentLikeState;

  const ToggleLikeStoryEvent({required this.storyId, required this.currentLikeState});

  @override
  List<Object?> get props => [storyId, currentLikeState];
}

class RealtimeStoryViewedEvent extends StoryEvent {
  final Map<String, dynamic> data;

  const RealtimeStoryViewedEvent(this.data);

  @override
  List<Object?> get props => [data];
}
