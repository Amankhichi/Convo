import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/contact/datasource/contact_datasource.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

String normalizeNumber(String number) {
  number = number.replaceAll(RegExp(r'\D'), '');
  if (number.length > 10) {
    number = number.substring(number.length - 10);
  }
  return number;
}

class ContactUsecase {
  final ContactDatasource datasource;

  ContactUsecase({required this.datasource});

  Future<List<UserModel>> call() async {
    final apiContacts = await datasource.getUsers();

    final phoneContacts = await FlutterContacts.getContacts(
      withProperties: true,
    );

    final prefs = await SharedPreferences.getInstance();
    final myNumber = prefs.getString("phone") ?? "";
    final Map<String, UserModel> apiUsersByPhone = {
      for (final user in apiContacts) normalizeNumber(user.phone): user,
    };

    final Set<Contact> phoneNumbers = phoneContacts
        .where((c) => c.phones.isNotEmpty)
        .toSet();

    final List<UserModel> matchedContacts = [];

    for (final c in phoneNumbers) {
      final user = apiUsersByPhone[normalizeNumber(c.phones.first.number)];
      if (c.phones.first.number == myNumber) continue;
      if (user != null) {
        print("NAME:" + c.displayName);
        user.copyWith(name: c.displayName);
        print("22contactname$c.displayName");
        matchedContacts.add(
          UserModel(
            id: user.id,
            name: c.displayName,
            nickname: user.nickname,
            phone: user.phone,
            about: user.about,
            profile: user.profile,
            online: user.online,
          ),
        );
      }
    }
    return matchedContacts;
  }
}

Future<String> nameInPhone(String phone) async {
  final normalizedPhone = normalizeNumber(phone);

  final phoneContacts = await FlutterContacts.getContacts(
    withProperties: true,
  );

  for (final contact in phoneContacts) {
    for (final p in contact.phones) {
      if (normalizeNumber(p.number) == normalizedPhone) {
        return contact.displayName;
      }
    }
  }

  return "";
}
