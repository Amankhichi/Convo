import 'dart:convert';

import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDatasource {

Future<bool> addUser(UserPayload user) async {
  print("API Calling...");

  final response = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/user/add"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(user.toJson()),
  );

  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  return response.statusCode == 200;
}

  Future<UserModel?> isUser({required String phone}) async {
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/user/all"),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);

        final userData = data
            .where((e) => e['phone'].toString() == phone)
            .toList();

        if (userData.isEmpty) return null;
        print("userData $userData");

        return UserModel.fromJson(userData.first);
      } else {
        print("❌ Get user failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Error: $e");
      return null;
    }
  }

Future<List<HomeChatModel>> getHomeChats() async {
  final prefs = await SharedPreferences.getInstance();

  final myId = int.tryParse(prefs.getString("id") ?? "");

  if (myId == null) {
    throw Exception("Invalid User ID");
  }

  final response = await http.get(
    Uri.parse("${ApiConfig.baseUrl}/chat/all"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  );

  if (response.statusCode != 200) {
    throw Exception("API Failed");
  }

  final List data = jsonDecode(response.body);

  final chats = data.where((e) =>e["sender_id"]?["id"] == myId ||e["receiver_id"]?["id"] == myId,)
      .map((e) => HomeChatModel.fromJson(e))
      .toList();

  if (chats.isEmpty) {
    throw Exception("No chats found");
  }

  return chats;
}

Future<UserModel> updateOnlineStatus({
  required int id,
  required bool online,
}) async {

  try {

    print("🟡 API CALL START");

    final url =
        "${ApiConfig.baseUrl}/user/status?id=$id&online=$online";

    print("🌐 URL: $url");

    final res = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    print("✅ STATUS CODE: ${res.statusCode}");
    print("📦 RESPONSE BODY: ${res.body}");

    final data = jsonDecode(res.body);

    return UserModel.fromJson(data);

  } catch (e, stack) {

    print("🔥 ERROR updateOnlineStatus");
    print(e);
    print(stack);

    rethrow;
  }
}


}
