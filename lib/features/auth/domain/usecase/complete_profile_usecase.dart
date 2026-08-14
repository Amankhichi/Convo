import '../../data/payload/user_payload.dart';
import '../repository/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository repository;

  CompleteProfileUseCase({required this.repository});

  Future<bool> call(UserPayload payload) {
    return repository.completeProfile(payload);
  }
}
