import '../repository/chat_repository.dart';

class SeenMssgUsecase {
  final ChatRepository repository;

  SeenMssgUsecase({required this.repository});

  Future<void> call({required int senderId, required int receiverId}) {
    return repository.seenMessage(senderId: senderId, receiverId: receiverId);
  }
}
