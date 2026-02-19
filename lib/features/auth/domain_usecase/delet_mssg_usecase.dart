import 'package:convo/features/auth/datasource/chat_datasource.dart';

class DeletMssgUsecase {
  final ChatDatasource datasource;

  DeletMssgUsecase({required this.datasource});

  Future<bool> call({required int mssgId}) {
    return datasource.deleteMessage(mssgId: mssgId);
  }
}

