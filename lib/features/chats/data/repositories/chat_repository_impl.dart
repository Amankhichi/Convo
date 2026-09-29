import 'package:convo/features/chats/data/datasources/chat_local_datasource.dart';
import 'package:convo/features/chats/data/datasources/chat_remote_datasource.dart';
import 'package:convo/features/chats/data/models/message_model.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';
import 'package:convo/features/chats/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;

  ChatRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<int> getOrCreateChatId(int targetUserId) async {
    final cachedId = _localDataSource.getChatId(targetUserId);
    if (cachedId != null && cachedId > 0) {
      return cachedId;
    }

    try {
      final chatId = await _remoteDataSource.createOrGetChatId(targetUserId);
      await _localDataSource.saveChatId(targetUserId, chatId);
      return chatId;
    } catch (e) {
      if (cachedId != null) return cachedId;
      rethrow;
    }
  }

  @override
  int? getCachedChatId(int targetUserId) {
    return _localDataSource.getChatId(targetUserId);
  }

  @override
  Future<List<MessageEntity>> fetchMessages(int chatId) async {
    try {
      final remoteMessages = await _remoteDataSource.fetchMessages(chatId);
      await _localDataSource.saveMessages(chatId, remoteMessages);
      return remoteMessages;
    } catch (e) {
      final cached = _localDataSource.getCachedMessages(chatId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  List<MessageEntity> getCachedMessages(int chatId) {
    return _localDataSource.getCachedMessages(chatId);
  }

  @override
  Future<MessageEntity> sendMessage({
    required int chatId,
    required int receiverId,
    required String content,
    String type = "TEXT",
    String? mediaUrl,
    int? replyToId,
    StoryReplyEntity? storyReply,
  }) async {
    final sentMessage = await _remoteDataSource.sendMessage(
      chatId: chatId,
      receiverId: receiverId,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      replyToId: replyToId,
      storyReply: storyReply,
    );

    // Save newly sent message into local cache list
    final cached = _localDataSource.getCachedMessages(chatId);
    final updatedList = [...cached, sentMessage];
    await saveCachedMessages(chatId, updatedList);

    return sentMessage;
  }

  @override
  Future<MessageEntity> editMessage(int messageId, String content) async {
    final editedMessage = await _remoteDataSource.editMessage(messageId, content);
    final cached = _localDataSource.getCachedMessages(editedMessage.chatId);
    final idx = cached.indexWhere((m) => m.id == editedMessage.id);
    if (idx != -1) {
      cached[idx] = editedMessage;
      await saveCachedMessages(editedMessage.chatId, cached);
    }
    return editedMessage;
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    await _remoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<void> saveCachedMessages(int chatId, List<MessageEntity> messages) async {
    final models = messages.map((m) {
      if (m is MessageModel) return m;
      return MessageModel.fromEntity(m);
    }).toList();
    await _localDataSource.saveMessages(chatId, models);
  }
}
