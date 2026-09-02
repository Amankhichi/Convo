import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/chats/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<int> createOrGetChatId(int targetUserId);
  Future<List<MessageModel>> fetchMessages(int chatId);
  Future<MessageModel> sendMessage({
    required int chatId,
    required int receiverId,
    required String content,
    String type = "TEXT",
    String? mediaUrl,
    int? replyToId,
  });
  Future<MessageModel> editMessage(int messageId, String content);
  Future<void> deleteMessage(int messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl(this._apiClient);

  @override
  Future<int> createOrGetChatId(int targetUserId) async {
    final body = {"targetUserId": targetUserId};
    final res = await _apiClient.post(ApiConfig.chats, body: body);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to create or get chat");
      }
      final data = res["data"];
      if (data is Map<String, dynamic>) {
        final chatId = data["chatId"] ?? data["id"];
        if (chatId is int) return chatId;
        if (chatId != null) return int.parse(chatId.toString());
      }
    }
    throw Exception("Invalid response structure from create chat API");
  }

  @override
  Future<List<MessageModel>> fetchMessages(int chatId) async {
    final res = await _apiClient.get("${ApiConfig.chats}/$chatId/messages");

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to fetch messages");
      }
      final data = res["data"];
      List<dynamic>? contentList;

      if (data is Map<String, dynamic> && data["content"] is List) {
        contentList = data["content"] as List;
      } else if (data is List) {
        contentList = data;
      }

      if (contentList != null) {
        return contentList
            .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    throw Exception("Invalid response structure from fetch messages API");
  }

  @override
  Future<MessageModel> sendMessage({
    required int chatId,
    required int receiverId,
    required String content,
    String type = "TEXT",
    String? mediaUrl,
    int? replyToId,
  }) async {
    final body = {
      "chatId": chatId,
      "receiverId": receiverId,
      "type": type,
      "content": content,
      "mediaUrl": mediaUrl,
      "replyToId": replyToId,
    };

    final res = await _apiClient.post(ApiConfig.messages, body: body);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to send message");
      }
      final data = res["data"];
      if (data is Map<String, dynamic>) {
        return MessageModel.fromJson(data);
      }
    }
    throw Exception("Invalid response structure from send message API");
  }

  @override
  Future<MessageModel> editMessage(int messageId, String content) async {
    final body = {"content": content};
    final res = await _apiClient.put("${ApiConfig.messages}/$messageId", body: body);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to edit message");
      }
      final data = res["data"];
      if (data is Map<String, dynamic>) {
        return MessageModel.fromJson(data);
      }
    }
    throw Exception("Invalid response structure from edit message API");
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    final res = await _apiClient.delete("${ApiConfig.messages}/$messageId");
    if (res is Map<String, dynamic> && res["success"] == false) {
      throw Exception(res["message"] ?? "Failed to delete message");
    }
  }
}
