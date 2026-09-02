import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/home/data/models/chat_summary_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ChatSummaryModel>> fetchChats();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _apiClient;

  HomeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ChatSummaryModel>> fetchChats() async {
    final res = await _apiClient.get(ApiConfig.chats);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to fetch chats");
      }
      final dataList = res["data"];
      if (dataList is List) {
        final chats = dataList
            .map((item) => ChatSummaryModel.fromJson(item as Map<String, dynamic>))
            .where((chat) {
              // Rule 1: Only DIRECT chats
              if (chat.chatType == "SYSTEM") return false;

              // Rule 2: Must have actual lastMessage (lastMessage != null)
              return chat.lastMessageContent.trim().isNotEmpty || chat.lastMessageTime.trim().isNotEmpty;
            })
            .toList();

        // Rule 3: Sort by latest message time, newest first
        chats.sort((a, b) {
          if (a.lastMessageTime.isEmpty) return 1;
          if (b.lastMessageTime.isEmpty) return -1;
          try {
            final dtA = DateTime.parse(a.lastMessageTime);
            final dtB = DateTime.parse(b.lastMessageTime);
            return dtB.compareTo(dtA);
          } catch (_) {
            return 0;
          }
        });

        return chats;
      }
      return [];
    }
    throw Exception("Invalid response structure from GET /api/chats");
  }
}
