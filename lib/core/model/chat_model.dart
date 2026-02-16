class ChatModel {
  final int id;
  final String senderId;
  final String receiverId;
  final String message;
  final String reply;
  final DateTime? createdAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.reply,
    this.createdAt,
  });

  // 🔹 JSON → Dart
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"] ?? "",
      senderId: json["senderId"] ?? "",
      receiverId: json["receiverId"] ?? "",
      message: json["mssg"] ?? "",
      reply: json["reply"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
    );
  }

  // 🔹 Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      "id":id,
      "senderId": senderId,
      "receiverId": receiverId,
      "mssg": message,
      "reply": reply,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}
