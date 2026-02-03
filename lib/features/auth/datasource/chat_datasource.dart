import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:http/http.dart' as http;

class ChatDatasource {

    // Set user Data
  Future<bool> sendMssg(ChatPayload chat) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/user_list",
    );

    final response = await http.post(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: jsonEncode(chat.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("User data added successfully!");
      return true;
    } else {
      print("Failed to add user data: ${response.statusCode}");
      print("Response: ${response.body}");
      return false;
    }
  }
}