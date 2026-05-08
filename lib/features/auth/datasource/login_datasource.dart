import 'dart:convert';

import 'package:convo/core/const.dart/api_config.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;

class LoginDatasource {

Future<bool> updateUser(UserPayload payload) async {

  try {

    final url = "${ApiConfig.baseUrl}/user/update";

    final res = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload.toJson()),
    );

    return res.statusCode == 200;

  } catch (e) {

    print(e);

    return false;
  }
}

}
