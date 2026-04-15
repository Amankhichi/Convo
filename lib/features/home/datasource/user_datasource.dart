import 'dart:convert';

import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDatasource {


 Future<bool> addUser(UserPayload user) async {
  try {
    print("URL: ${ApiConfig.baseUrl}/user/add");
    print("BODY: ${jsonEncode(user.toJson())}");

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/user/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("Catch Error: $e");
    return false;
  }
}

Future<UserModel?> isUser({required String phone}) async {
  try {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/user/all"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      final userData = data.where(
        (e) => e['phone'].toString() == phone,
      ).toList();

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
    print("getChats function called");

    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString("id");

    print("User ID = $idString");

    if (idString == null) {
      print("❌ ID not found in SharedPreferences");
      return [];
    }

    final id = int.parse(idString);

    final url = Uri.parse(
      'https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/chats?select=*,sender:senderId(*),receiver:receiverId(*)&or=("senderId".eq.$id,"receiverId".eq.$id)&order=created_at.asc',
    );

    final response = await http.get(
      url,
      headers: {
        "apikey": apikey,
        "Authorization": "Bearer $apikey",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
    print("Status Code = ${response.statusCode}");
    print("Response Body = ${response.body}");

    if (response.statusCode == 200) {
      print("✅ getChats success");
      final List data = jsonDecode(response.body);
      return data.map((e) => HomeChatModel.fromJson(e)).toList();
    } else {
      print("❌ getChats fail");
      return [];
    }
  }



}
