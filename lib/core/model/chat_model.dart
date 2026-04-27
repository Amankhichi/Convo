class ChatModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final int? replyTo;
  final ChatModel? reply;
  final bool seen;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.replyTo,
    this.reply,
    required this.seen,
    required this.createdAt,
  });

  // 🔹 JSON → Dart
factory ChatModel.fromJson(Map<String, dynamic> json) {
  return ChatModel(
    id: json["id"] ?? 0,

    /// 🔥 FIX nested object
    senderId: json["sender_id"]?["id"] ?? 0,
    receiverId: json["receiver_id"]?["id"] ?? 0,

    /// 🔥 message key
    message: json["massage"] ?? "",

    /// 🔥 reply
    replyTo: int.tryParse(json["replyTo"]?.toString() ?? ''),

    seen: json["seen"] ?? false,

    /// 🔥 no nested reply object in your API currently
    reply: null,

    /// 🔥 FIX createdAt
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
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
      "reply_to": replyTo,
      "seen": seen,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
