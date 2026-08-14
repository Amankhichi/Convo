import 'package:convo/features/home/data/model/home_chat_model.dart';

import '../repository/home_repository.dart';

class GetHomeChatsListUsecase {
  final HomeRepository repository;

  GetHomeChatsListUsecase({required this.repository});

  Future<List<HomeChatModel>> call() {
    return repository.getHomeChats();
  }
}
