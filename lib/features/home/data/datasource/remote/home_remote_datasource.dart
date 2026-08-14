import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../auth/data/model/user_model.dart';
import '../../model/home_chat_model.dart';

abstract class HomeRemoteDatasource {
  Future<List<HomeChatModel>> getHomeChats();
  Future<UserModel> updateOnlineStatus({required int id, required bool online});
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final ApiClient _apiClient;

  HomeRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<HomeChatModel>> getHomeChats() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = int.tryParse(prefs.getString("id") ?? "");

    if (myId == null) {
      throw Exception("Invalid User ID");
    }

    final response = await _apiClient.get(ApiEndpoints.allChats);

    if (response.statusCode != 200) {
      throw Exception("API Failed");
    }

    final List data = response.data;

    final chats = data
        .where((e) => e["sender_id"]?["id"] == myId || e["receiver_id"]?["id"] == myId)
        .map((e) => HomeChatModel.fromJson(e))
        .toList();

    return chats;
  }

  @override
  Future<UserModel> updateOnlineStatus({required int id, required bool online}) async {
    final url = "${ApiEndpoints.updateStatus}?id=$id&online=$online";
    final response = await _apiClient.put(url);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }
    throw Exception("Failed to update status");
  }
}
