import 'package:convo/core/model/user_model.dart';

class HomeChatModel {
  final int id;
  final DateTime createdAt;
  final int senderId;
  final int receiverId;
  final String message;
  final bool seen;
  final int unSeencount;
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
    required this.seen,
    required this.unSeencount
  });

  factory HomeChatModel.fromJson(Map<String, dynamic> json) {
    return HomeChatModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['mssg'] ?? '',
      replyTo: json['reply_to'],
      seen: json['seen'] ?? false,
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
      unSeencount: 0
    );
  }

  HomeChatModel copyWith({
    int? id,
    DateTime? createdAt,
    int? senderId,
    int? receiverId,
    String? message,
    int? replyTo,
    int? unSeencount,
    bool? seen,
    UserModel? sender,
    UserModel? receiver,
  }) {
    return HomeChatModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      replyTo: replyTo ?? this.replyTo,
      seen: seen ?? this.seen,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      unSeencount: unSeencount ??this.unSeencount
    );
  }
}