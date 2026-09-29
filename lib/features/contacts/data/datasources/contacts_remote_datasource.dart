import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/contacts/data/models/contact_model.dart';

abstract class ContactsRemoteDataSource {
  Future<List<ContactModel>> syncContacts({
    required List<Map<String, dynamic>> contacts,
    required List<String> phoneNumbers,
  });
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  final ApiClient _apiClient;

  ContactsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ContactModel>> syncContacts({
    required List<Map<String, dynamic>> contacts,
    required List<String> phoneNumbers,
  }) async {
    final body = {
      "contacts": contacts,
      "phoneNumbers": phoneNumbers,
    };

    final res = await _apiClient.post(ApiConfig.syncContacts, body: body);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to sync contacts");
      }
      final dataList = res["data"];
      if (dataList is List) {
        return dataList.map((item) => ContactModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    }

    throw Exception("Invalid response structure from contacts sync API");
  }
}
