import 'dart:convert';

import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/chat_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:http/http.dart' as http;

class ChatDatasource {
  Future<bool> sendMssg(ChatPayload mssg) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/add");

      final body = jsonEncode(mssg.toJson());

      print("📤 URL: $url");
      print("📤 Body: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("🚨 Exception: $e");
      return false;
    }
  }

  // Set user Data
  Future<List<ChatModel>> getMessages({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final url = Uri.parse(
  "${ApiConfig.baseUrl}/chat/between?senderId=$senderId&receiverId=$receiverId",
);
// http://192.168.1.14:7000/chat/between?senderId=102&receiverId=2
      print("📡 URL: $url $senderId $receiverId");
      print("📡 URL sender:  $senderId ");
      print("📡 URL reciver: $receiverId");

      final res = await http
          .get(url, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 10));

      print("📊 Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) {
          return decoded.map((e) => ChatModel.fromJson(e)).toList();
        }
      } else {
        print("❌ API Error: ${res.body}");
      }
    } catch (e) {
      print("❌ get mssg error: $e");
      print("URL API &url");
    }

    return [];
  }

  Future<bool> deleteMessage({required int mssgId}) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/chat/delete?id=eq.$mssgId");

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
    final url = Uri.parse("${ApiConfig.baseUrl}/chat/find?id=$msgId");

    final res = await http.put(
      url, // or PATCH depending on backend
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mssg": newMessage}),
    );

    print("Status: ${res.statusCode}");
    print("Response: ${res.body}");

    return res.statusCode == 200;
  }

  Future<void> seenMssg({
    required int senderId,
    required int receiverId,
  }) async {
    final url = Uri.parse(
      "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats?senderId=eq.$senderId&receiverId=eq.$receiverId",
    );

    await http.patch(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
      },
      body: jsonEncode({"seen": true}),
    );
  }

  // Future<bool> createGroup({
  //   required int msgId,
  //   required String newMessage,
  // }) async {
  //   final url = Uri.parse(
  //     "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/group_table",
  //   );
  //   final res = await http.patch(
  //     url,
  //     headers: {
  //       "apikey": apikey,
  //       "Authorization": "Bearer $apikey",
  //       "Content-Type": "application/json",
  //       "Prefer": "return=minimal",
  //     },
  //     body: jsonEncode({"mssg": newMessage}),
  //   );
  //   print("Edit Status: ${res.statusCode}");
  //   return res.statusCode == 200 || res.statusCode == 204;
  // }
}
