class ChatModel {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime? createdAt;

  ChatModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.createdAt,
  });

  // 🔹 JSON → Dart
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      senderId: json["senderId"] ?? "",
      receiverId: json["receiverId"] ?? "",
      message: json["mssg"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
    );
  }

  // 🔹 Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "mssg": message,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}
