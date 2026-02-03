import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactUsecase {
  final UserDatasource datasource;

  ContactUsecase({required this.datasource});

Future<List<UserModel>> call() async {
  final apiContacts = await datasource.getUser();

  final phoneContacts = await FlutterContacts.getContacts(
    withProperties: true,
  );

  final Set<UserModel> apiNumbers = apiContacts.map((user) {
    String number = user.phone;

    number = number.replaceAll(RegExp(r'\D'), '');

    if (number.length > 10) {
      number = number.substring(number.length - 10);
    }

    return user;
  }).toSet();

  final Set<String> phoneNumbers = phoneContacts.map((contact) {
     String number = contact.phones.first.number;
    number = number.replaceAll(RegExp(r'\D'), '');

    if (number.length > 10) {
      number = number.substring(number.length - 10);
    }

    return number;
  }).toSet();

  final List<UserModel> matchedContacts = [];

  for (final contact in apiNumbers) {
    if (phoneNumbers.contains(contact.phone)) {
      matchedContacts.add(contact);
    }
  }

  return matchedContacts;
}

}
