import '../../data/payload/user_payload.dart';
import '../repository/auth_repository.dart';

class AddUserUsecase {
  final AuthRepository repository;

  AddUserUsecase({required this.repository});

  Future<bool> call(UserPayload payload) {
    return repository.completeProfile(payload);
  }
}
