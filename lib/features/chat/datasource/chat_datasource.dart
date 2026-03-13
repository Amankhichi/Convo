import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/chat_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:http/http.dart' as http;

class ChatDatasource {
  Future<bool> sendMssg(ChatPayload mssg) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats",
    );

    final response = await http.post(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: jsonEncode(mssg.toJson()),
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

  // Set user Data
  Future<List<ChatModel>> getMessages({
    required String senderId,
    required String receiverId,
  }) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats"
      '?select=*,reply:reply_to(*)&or=(and("senderId".eq.$senderId,"receiverId".eq.$receiverId),and("senderId".eq.$receiverId,"receiverId".eq.$senderId))&order=created_at.asc',
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

  Future<bool> deleteMessage({required int mssgId}) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats?id=eq.$mssgId",
    );

    final response = await http.delete(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal", // IMPORTANT for delete
      },
    );

    if (response.statusCode == 204) {
      print("✅ Message Deleted Successfully");
      return true;
    } else {
      print("❌ Delete Failed: ${response.statusCode}");
      print("❌ Body: ${response.body}");
      return false;
    }
  }

  Future<bool> editMssg({
    required int msgId,
    required String newMessage,
  }) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats?id=eq.$msgId",
    );

    final res = await http.patch(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: jsonEncode({"mssg": newMessage}),
    );

    print("Edit Status: ${res.statusCode}");
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<bool> createGroup({
    required int msgId,
    required String newMessage,
  }) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/group_table",
    );

    final res = await http.patch(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: jsonEncode({"mssg": newMessage}),
    );

    print("Edit Status: ${res.statusCode}");
    return res.statusCode == 200 || res.statusCode == 204;
  }



}
