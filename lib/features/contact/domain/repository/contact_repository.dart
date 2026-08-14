import '../../../auth/domain/entity/user_entity.dart';

abstract class ContactRepository {
  Future<List<UserEntity>> getUsers();
}
