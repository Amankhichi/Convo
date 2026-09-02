import 'dart:convert';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/contacts/data/models/contact_model.dart';

abstract class ContactsLocalDataSource {
  Future<void> saveContacts(List<ContactModel> contacts);
  List<ContactModel> getCachedContacts();
}

class ContactsLocalDataSourceImpl implements ContactsLocalDataSource {
  final LocalStorage _localStorage;

  ContactsLocalDataSourceImpl(this._localStorage);

  @override
  Future<void> saveContacts(List<ContactModel> contacts) async {
    final jsonList = contacts.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _localStorage.setString(StorageKeys.syncedContacts, jsonString);
  }

  @override
  List<ContactModel> getCachedContacts() {
    final jsonString = _localStorage.getString(StorageKeys.syncedContacts);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => ContactModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
