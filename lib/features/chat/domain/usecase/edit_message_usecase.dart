import '../repository/chat_repository.dart';

class EditMessageUseCase {
  final ChatRepository repository;

  EditMessageUseCase({required this.repository});

  Future<bool> call({required int msgId, required String newMessage}) {
    return repository.editMessage(messageId: msgId, newMessage: newMessage);
  }
}
