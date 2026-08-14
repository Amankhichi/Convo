import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../model/chat_model.dart';
import '../../payload/chat_payload.dart';

abstract class ChatRemoteDatasource {
  Future<bool> sendMessage(ChatPayload message);
  Future<List<ChatModel>> getMessages({required String senderId, required String receiverId});
  Future<bool> deleteMessage({required int messageId});
  Future<bool> editMessage({required int messageId, required String newMessage});
  Future<void> seenMessage({required int senderId, required int receiverId});
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final ApiClient _apiClient;

  ChatRemoteDatasourceImpl(this._apiClient);

  @override
  Future<bool> sendMessage(ChatPayload message) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addChat,
        data: message.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Send Message Remote Error: $e");
      return false;
    }
  }

  @override
  Future<List<ChatModel>> getMessages({required String senderId, required String receiverId}) async {
    try {
      final response = await _apiClient.get(
        "${ApiEndpoints.chatsBetween}?senderId=$senderId&receiverId=$receiverId",
      );
      if (response.statusCode == 200) {
        final decoded = response.data;
        if (decoded is List) {
          return decoded.map((e) => ChatModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Get Messages Remote Error: $e");
      return [];
    }
  }

  @override
  Future<bool> deleteMessage({required int messageId}) async {
    try {
      final response = await _apiClient.delete(
        "${ApiEndpoints.deleteChat}?id=$messageId",
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Delete Message Remote Error: $e");
      return false;
    }
  }

  @override
  Future<bool> editMessage({required int messageId, required String newMessage}) async {
    try {
      final response = await _apiClient.put(
        "${ApiEndpoints.updateChat}?id=$messageId",
        data: {"massage": newMessage},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Edit Message Remote Error: $e");
      return false;
    }
  }

  @override
  Future<void> seenMessage({required int senderId, required int receiverId}) async {
    try {
      await _apiClient.put(
        "${ApiEndpoints.seenChat}?senderId=$senderId&receiverId=$receiverId",
      );
    } catch (e) {
      print("Seen Message Remote Error: $e");
    }
  }
}
