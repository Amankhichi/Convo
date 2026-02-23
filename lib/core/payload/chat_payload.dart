class ChatPayload {
  final int senderId;
  final int receiverId;
  final String mssg;
  final int? replyTo;

  ChatPayload({
    required this.senderId,
    required this.receiverId,
    required this.mssg,
    required this.replyTo,
  });

  Map<String, dynamic> toJson() => {
    "senderId": senderId,
    "receiverId": receiverId,
    "mssg": mssg,
    "reply_to": replyTo,
  };
}
