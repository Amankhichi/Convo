import 'dart:convert';

import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:http/http.dart' as http;

class ContactDatasource {


Future<List<UserModel>> getUsers() async {
  try {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/user/all"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      print("✅ Users fetched: ${data.length}");

      return data
          .map((e) => UserModel.fromJson(e))
          .toList();
    } else {
      print("❌ Get user failed: ${res.body}");
      return [];
    }
  } catch (e) {
    print("🔥 Error: $e");
    return [];
  }
}
}