import 'package:equatable/equatable.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeChatsEvent extends HomeEvent {}

class RealtimeHomeMessageReceivedEvent extends HomeEvent {
  final MessageEntity message;

  const RealtimeHomeMessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
