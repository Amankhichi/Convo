import 'dart:convert';

import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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







// Future<bool> addUser(UserPayload user) async {
 
//     var body = user.toJson();

//     var response = await http.post(
//       Uri.parse("http://$IpAddress:7000/user/add"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(body),
//     );

//     if (response.statusCode == 200) {
//       print("User data added successfully!");
//       return true;
//     } else {
//       print("Failed: ${response.statusCode}");
//       print("Response: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     print("Submit Error: $e");
//     return false; // ❗ important
//   }
// }