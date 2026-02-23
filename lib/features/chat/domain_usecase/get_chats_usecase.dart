import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/features/chat/datasource/chat_datasource.dart';

class GetChatsUseCase {
  final ChatDatasource datasource;

  GetChatsUseCase({required this.datasource});

  Future<List<HomeChatModel>> call() {
    return datasource.getChats();
  }
}