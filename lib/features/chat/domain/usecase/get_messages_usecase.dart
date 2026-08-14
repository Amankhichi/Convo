import '../../domain/entity/chat_entity.dart';
import '../repository/chat_repository.dart';

class GetMssgUseCase {
  final ChatRepository repository;

  GetMssgUseCase({required this.repository});

  Future<List<ChatEntity>> call({required String senderId, required String receiverId}) {
    return repository.getMessages(senderId: senderId, receiverId: receiverId);
  }
}
