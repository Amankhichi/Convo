import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:http/http.dart' as http;

class ContactDatasource {


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
    print("Success get user ");
    final List data = jsonDecode(res.body);
    return data.map((e) => UserModel.fromJson(e)).toList();
  } else {
    print("❌ Get user failed: ${res.body}");
    return [];
  }
} 
}