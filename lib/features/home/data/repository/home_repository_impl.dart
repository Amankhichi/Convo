import '../../../auth/domain/entity/user_entity.dart';
import '../../domain/repository/home_repository.dart';
import '../datasource/remote/home_remote_datasource.dart';
import '../model/home_chat_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource remoteDatasource;

  HomeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<HomeChatModel>> getHomeChats() {
    return remoteDatasource.getHomeChats();
  }

  @override
  Future<UserEntity> updateOnlineStatus({required int id, required bool online}) {
    return remoteDatasource.updateOnlineStatus(id: id, online: online);
  }
}
