import '../../../auth/domain/entity/user_entity.dart';
import '../../data/model/home_chat_model.dart';

abstract class HomeRepository {
  Future<List<HomeChatModel>> getHomeChats();
  Future<UserEntity> updateOnlineStatus({required int id, required bool online});
}
