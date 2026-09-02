import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.deleteAccount();
  }
}
