import '../../../auth/domain/entity/user_entity.dart';
import '../repository/home_repository.dart';

class UpdateOnlineStatusUseCase {
  final HomeRepository repository;

  UpdateOnlineStatusUseCase(this.repository);

  Future<UserEntity> call({required int id, required bool online}) {
    return repository.updateOnlineStatus(id: id, online: online);
  }
}
