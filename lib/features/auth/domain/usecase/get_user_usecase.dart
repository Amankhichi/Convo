import '../entity/user_entity.dart';
import '../repository/auth_repository.dart';

class GetUserUsecase {
  final AuthRepository repository;

  GetUserUsecase({required this.repository});

  Future<UserEntity?> call({required String phone}) {
    return repository.getUser(phone);
  }
}
