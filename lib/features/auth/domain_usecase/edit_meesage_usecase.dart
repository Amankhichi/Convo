import 'package:convo/features/auth/datasource/chat_datasource.dart';

class EditMessageUseCase {
  final ChatDatasource datasource;
  EditMessageUseCase({required this.datasource});

  Future<bool> call({required int msgId, required String newMessage}) {
    return datasource.editMssg(msgId: msgId, newMessage: newMessage);
  }
}
