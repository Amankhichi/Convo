import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';

class GetUserUsecase {
  final UserDatasource datasource;

  GetUserUsecase({required this.datasource});

  Future<UserModel?> call({required String phone}) async {
    return datasource.isUser(phone: phone);
  }
}

