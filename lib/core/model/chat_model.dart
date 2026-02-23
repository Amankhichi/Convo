class ChatModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final int? replyTo;
  final ChatModel? reply; 
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.replyTo,
    this.reply,
    required this.createdAt,
  });

  // 🔹 JSON → Dart
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"],
      senderId: json["senderId"],
      receiverId: json["receiverId"],
      message: json["mssg"] ?? "",
      replyTo: json["reply_to"],
      reply: json["reply"] != null
          ? ChatModel.fromJson(json["reply"])
          : null,
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  // 🔹 Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "mssg": message,
      "reply_to": replyTo,
      "created_at": createdAt.toIso8601String(),
    };
  }
}