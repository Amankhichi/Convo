import '../../domain/entity/chat_entity.dart';
import '../model/chat_model.dart';

class ChatMapper {
  static ChatEntity toEntity(ChatModel model) {
    return ChatEntity(
      id: model.id,
      senderId: model.senderId,
      receiverId: model.receiverId,
      message: model.message,
      replyTo: model.replyTo,
      reply: model.reply != null ? toEntity(model.reply as ChatModel) : null,
      seen: model.seen,
      createdAt: model.createdAt,
    );
  }

  static ChatModel toModel(ChatEntity entity) {
    return ChatModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      message: entity.message,
      replyTo: entity.replyTo,
      reply: entity.reply != null ? toModel(entity.reply!) : null,
      seen: entity.seen,
      createdAt: entity.createdAt,
    );
  }
}
