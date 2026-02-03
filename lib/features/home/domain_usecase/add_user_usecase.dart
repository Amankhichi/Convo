import 'package:convo/core/payload/user_payload.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';

class AddUserUsecase{
  final UserDatasource datasource;
  AddUserUsecase ({required this.datasource});
  Future<bool> call(UserPayload user){
    return datasource.addUser(user);
  }
}