import '../../data/payload/chat_payload.dart';
import '../repository/chat_repository.dart';

class SendMssgUsecase {
  final ChatRepository repository;

  SendMssgUsecase({required this.repository});

  Future<bool> call(ChatPayload message) {
    return repository.sendMessage(message);
  }
}
