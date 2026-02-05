import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;

class UserDatasource {

  // Set user Data
  Future<bool> addUser(UserPayload user) async {
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
      body: jsonEncode(user.toJson()),
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


Future<List<UserModel>> getUsers() async {
  final url = Uri.parse(
    "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/user_list?select=*",
  );

  final res = await http.get(
    url,
    headers: {
      "apikey": apikey,
      "Authorization": "Bearer $apikey",
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((e) => UserModel.fromJson(e)).toList();
  } else {
    print("❌ Get user failed: ${res.body}");
    return [];
  }
}

Future<UserModel?> isUser({required String phone}) async {
  final url = Uri.parse(
    "https://ehmqgiqrfpvvznvsvfyu.supabase.co/rest/v1/user_list?phone=eq.$phone",
  );

  final res = await http.get(
    url,
    headers: {
      "apikey": apikey,
      "Authorization": "Bearer $apikey",
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    print("Get user success: ${res.body}");


    if (data.isEmpty) return null;

    return UserModel.fromJson(data.first);
  } else {
    print("Get user failed: ${res.body}");
    return null;
  }
}

  Future<bool> sendMssg(ChatPayload mssg) async {
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



}