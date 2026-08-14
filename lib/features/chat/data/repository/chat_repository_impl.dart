import '../../domain/entity/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasource/remote/chat_remote_datasource.dart';
import '../payload/chat_payload.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<bool> sendMessage(ChatPayload message) {
    return remoteDatasource.sendMessage(message);
  }

  @override
  Future<List<ChatEntity>> getMessages({required String senderId, required String receiverId}) async {
    return await remoteDatasource.getMessages(senderId: senderId, receiverId: receiverId);
  }

  @override
  Future<bool> deleteMessage({required int messageId}) {
    return remoteDatasource.deleteMessage(messageId: messageId);
  }

  @override
  Future<bool> editMessage({required int messageId, required String newMessage}) {
    return remoteDatasource.editMessage(messageId: messageId, newMessage: newMessage);
  }

  @override
  Future<void> seenMessage({required int senderId, required int receiverId}) {
    return remoteDatasource.seenMessage(senderId: senderId, receiverId: receiverId);
  }
}
