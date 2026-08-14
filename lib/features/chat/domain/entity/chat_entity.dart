import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final int? replyTo;
  final ChatEntity? reply;
  final bool seen;
  final DateTime createdAt;

  const ChatEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.replyTo,
    this.reply,
    required this.seen,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, senderId, receiverId, message, replyTo, reply, seen, createdAt];
}
