import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../auth/data/model/user_model.dart';

abstract class ContactRemoteDatasource {
  Future<List<UserModel>> getUsers();
}

class ContactRemoteDatasourceImpl implements ContactRemoteDatasource {
  final ApiClient _apiClient;

  ContactRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allUsers);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("ContactRemoteDatasource Error: $e");
      return [];
    }
  }
}
