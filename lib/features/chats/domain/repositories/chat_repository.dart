import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';

abstract class ChatRepository {
  Future<int> getOrCreateChatId(int targetUserId);
  int? getCachedChatId(int targetUserId);
  Future<List<MessageEntity>> fetchMessages(int chatId);
  List<MessageEntity> getCachedMessages(int chatId);
  Future<MessageEntity> sendMessage({
    required int chatId,
    required int receiverId,
    required String content,
    String type = "TEXT",
    String? mediaUrl,
    int? replyToId,
    StoryReplyEntity? storyReply,
  });
  Future<MessageEntity> editMessage(int messageId, String content);
  Future<void> deleteMessage(int messageId);
  Future<void> saveCachedMessages(int chatId, List<MessageEntity> messages);
}
