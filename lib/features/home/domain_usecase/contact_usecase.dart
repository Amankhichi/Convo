import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsecase {
  final UserDatasource datasource;

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

    final Set<String> phoneNumbers = phoneContacts
        .where((c) => c.phones.isNotEmpty)
        .map((c) => _normalizeNumber(c.phones.first.number))
        .toSet();

    final List<UserModel> matchedContacts = [];

    for (final number in phoneNumbers) {
      final user = apiUsersByPhone[number];
      if (number == myNumber) continue;
      if (user != null) {
        matchedContacts.add(user);
      }
    }

    return matchedContacts;
  }
}


