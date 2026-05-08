import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';

class UpdateOnlineStatusUseCase {
  final UserDatasource datasource;

  UpdateOnlineStatusUseCase(this.datasource);

  Future<UserModel> call({
    required bool online,
    required int id,
  }) {
    return datasource.updateOnlineStatus(
      online: online,
      id: id,
    );
  }
}