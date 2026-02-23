import 'package:convo/core/model/user_model.dart';

class HomeChatModel {
  final int id;
  final DateTime createdAt;
  final int senderId;
  final int receiverId;
  final String message;
  final int? replyTo;

  final UserModel sender;
  final UserModel receiver;

  HomeChatModel({
    required this.id,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.replyTo,
    required this.sender,
    required this.receiver,
  });

  factory HomeChatModel.fromJson(Map<String, dynamic> json) {
    return HomeChatModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['mssg'] ?? '',
      replyTo: json['reply_to'],
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
    );
  }
}