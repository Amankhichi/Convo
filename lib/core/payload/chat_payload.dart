class ChatPayload {
  final String senderId;
  final String receiverId;
  final String mssg;
  final String reply;


  ChatPayload({
    required this.senderId,
    required this.receiverId,
    required this.mssg,
    required this.reply,

  });

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "receiverId": receiverId,
        "mssg": mssg,
        "reply": reply,
      };

  // ✅ Convert JSON → Dart object
  factory ChatPayload.fromJson(Map<String, dynamic> json) => ChatPayload(
        senderId: json["senderId"],
        receiverId: json["receiverId"],
        mssg: json["mssg"],
        reply: json["reply"],

      );
}



