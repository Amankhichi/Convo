import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/contact/datasource/contact_datasource.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsecase {
  final ContactDatasource datasource;

  ContactUsecase({required this.datasource});

  String _normalizeNumber(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');
    if (number.length > 10) {
      number = number.substring(number.length - 10);
    }
    return number;
  }

  Future<List<UserModel>> call() async {
    final apiContacts = await datasource.getUsers();

    final phoneContacts = await FlutterContacts.getContacts(
      withProperties: true,
    );

    final prefs = await SharedPreferences.getInstance();
  final myNumber = prefs.getString("phone") ?? "";
  // final myNumber = _normalizeNumber(myNumber);

    final Map<String, UserModel> apiUsersByPhone = {
      for (final user in apiContacts)
        _normalizeNumber(user.phone): user,
    };

    final Set<Contact> phoneNumbers = phoneContacts
        .where((c) => c.phones.isNotEmpty)
        .toSet();

    final List<UserModel> matchedContacts = [];

    for (final c in phoneNumbers) {

      final user = apiUsersByPhone[ _normalizeNumber(c.phones.first.number)];
      user?.copyWith(name: c.displayName);
      if (c.phones.first.number == myNumber) continue;
      if (user != null) {
        matchedContacts.add(user);
      }
    }

    return matchedContacts;
  }
}


