class ChatModel {
  final int id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? reply; // ✅ nullable
  final DateTime createdAt; // ✅ NOT nullable

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.reply,
    required this.createdAt,
  });

  // 🔹 JSON → Dart
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"] ?? 0,
      senderId: json["senderId"] ?? "",
      receiverId: json["receiverId"] ?? "",
      message: json["mssg"] ?? "",
      reply: json["reply"] == null || json["reply"] == "null" || json["reply"] == ""
          ? null
          : json["reply"],

      // ✅ auto fallback time
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  // 🔹 Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "mssg": message,
      "reply": reply, // will store null if no reply
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
