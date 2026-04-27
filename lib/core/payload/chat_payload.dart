class ChatPayload {
  final int senderId;
  final int receiverId;
  final String massage; // ⚠️ same as backend
  final int replyTo;
  final bool seen;

  ChatPayload({
    required this.senderId,
    required this.receiverId,
    required this.massage,
    this.replyTo = 0,
    this.seen = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "massage": massage, // 🔥 FIXED
      "replyTo": replyTo,
      "seen": seen,
    };
  }
}