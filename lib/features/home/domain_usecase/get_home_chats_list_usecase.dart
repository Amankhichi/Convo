import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';

class GetHomeChatsListUsecase {
  final UserDatasource datasource;

  GetHomeChatsListUsecase({required this.datasource});

  Future<List<HomeChatModel>> call() {
    return datasource.getHomeChats();
  }
}