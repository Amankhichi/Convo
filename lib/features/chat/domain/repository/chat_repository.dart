import '../../domain/entity/chat_entity.dart';
import '../../data/payload/chat_payload.dart';

abstract class ChatRepository {
  Future<bool> sendMessage(ChatPayload message);
  Future<List<ChatEntity>> getMessages({required String senderId, required String receiverId});
  Future<bool> deleteMessage({required int messageId});
  Future<bool> editMessage({required int messageId, required String newMessage});
  Future<void> seenMessage({required int senderId, required int receiverId});
}
