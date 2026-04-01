import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;

class LoginDatasource {

  Future<bool> addUser(UserPayload user) async {
  try {
    final response = await http.post(
      Uri.parse("http://$IpAddress:7000/user/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error: ${response.body}");
      return false;
    }

  } catch (e) {
    print("Catch Error: $e");
    return false; // ✅ MUST return
  }
}
}
