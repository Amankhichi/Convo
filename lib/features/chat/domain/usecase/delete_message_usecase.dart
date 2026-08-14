import '../repository/chat_repository.dart';

class DeletMssgUsecase {
  final ChatRepository repository;

  DeletMssgUsecase({required this.repository});

  Future<bool> call({required int mssgId}) {
    return repository.deleteMessage(messageId: mssgId);
  }
}
