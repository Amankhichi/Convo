class ChatPayload {
  final String senderId;
  final String receiverId;
  final String mssg;

  ChatPayload({
    required this.senderId,
    required this.receiverId,
    required this.mssg,
  });

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "receiverId": receiverId,
        "mssg": mssg,
      };

  // ✅ Convert JSON → Dart object
  factory ChatPayload.fromJson(Map<String, dynamic> json) => ChatPayload(
        senderId: json["senderId"],
        receiverId: json["receiverId"],
        mssg: json["mssg"],
      );
}



