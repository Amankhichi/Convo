import 'package:equatable/equatable.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryFeedLoaded extends StoryState {
  final List<UserStoryGroupEntity> storyGroups;
  final UserStoryGroupEntity? myStories;

  const StoryFeedLoaded({
    required this.storyGroups,
    this.myStories,
  });

  @override
  List<Object?> get props => [storyGroups, myStories];
}

class StoryUploadingState extends StoryState {
  final double progress;

  const StoryUploadingState({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class StoryUploadedSuccess extends StoryState {}

class StoryViewersLoaded extends StoryState {
  final dynamic storyId;
  final int viewCount;
  final List<StoryViewerEntity> viewers;

  const StoryViewersLoaded({
    required this.storyId,
    required this.viewCount,
    required this.viewers,
  });

  @override
  List<Object?> get props => [storyId, viewCount, viewers];
}

class StoryDeletedSuccess extends StoryState {
  final dynamic storyId;

  const StoryDeletedSuccess(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class StoryError extends StoryState {
  final String message;

  const StoryError(this.message);

  @override
  List<Object?> get props => [message];
}
