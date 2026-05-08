import 'package:convo/core/payload/user_payload.dart';
import 'package:convo/features/auth/datasource/login_datasource.dart';

class UpdateUserUseCase {

  final LoginDatasource repo;

  UpdateUserUseCase(this.repo);

  Future<bool> call(UserPayload payload) async {

    return await repo.updateUser(payload);
  }
}