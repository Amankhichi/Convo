import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatDatasource {
  // Set user Data
  Future<List<ChatModel>> getMessages({
  required String senderId,
  required String receiverId,
}) async {

  final url = Uri.parse(
    "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats"
    "?or=(and(senderId.eq.$senderId,receiverId.eq.$receiverId),"
    "and(senderId.eq.$receiverId,receiverId.eq.$senderId))",
  );

  print("Sender: $senderId Receiver: $receiverId");
  print("URL: $url");

  final response = await http.get(
    url,
    headers: {
      "apikey": apikey,
      "Authorization": "Bearer $apikey",
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    print("Messages Response: ${response.body}");
    return data.map((e) => ChatModel.fromJson(e)).toList();
  } else {
    print("❌ Failed: ${response.statusCode}");
    print("❌ Body: ${response.body}");
    return [];
  }
}

}
