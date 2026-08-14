import '../../../auth/domain/entity/user_entity.dart';
import '../../domain/repository/contact_repository.dart';
import '../datasource/remote/contact_remote_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDatasource remoteDatasource;

  ContactRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<UserEntity>> getUsers() async {
    return await remoteDatasource.getUsers();
  }
}
