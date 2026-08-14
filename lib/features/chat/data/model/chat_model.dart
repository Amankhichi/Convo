import '../../domain/entity/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.message,
    super.replyTo,
    super.reply,
    required super.seen,
    required super.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"] ?? 0,
      senderId: json["sender_id"]?["id"] ?? 0,
      receiverId: json["receiver_id"]?["id"] ?? 0,
      message: json["massage"] ?? "",
      replyTo: int.tryParse(json["replyTo"]?.toString() ?? ''),
      seen: json["seen"] ?? false,
      reply: null,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "mssg": message,
      "reply_to": replyTo,
      "seen": seen,
      "created_at": createdAt.toIso8601String(),
    };
  }

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      message: entity.message,
      replyTo: entity.replyTo,
      reply: entity.reply != null ? ChatModel.fromEntity(entity.reply!) : null,
      seen: entity.seen,
      createdAt: entity.createdAt,
    );
  }
}
