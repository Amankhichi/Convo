import '../../data/payload/user_payload.dart';
import '../repository/auth_repository.dart';

class UpdateUserUsecase {
  final AuthRepository repository;

  UpdateUserUsecase({required this.repository});

  Future<bool> call(UserPayload payload) {
    return repository.updateUser(payload);
  }
}
