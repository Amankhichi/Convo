import 'package:convo/core/model/home_chat_model.dart';
import 'package:convo/features/contact/domain_usecase/contact_usecase.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetHomeChatsListUsecase {
  final UserDatasource datasource;

  GetHomeChatsListUsecase({required this.datasource});

  Future<List<HomeChatModel>> call() async {
    final list = await datasource.getHomeChats();
    if (!await FlutterContacts.requestPermission()) {
      return list; // return API data only
    }
    final phoneContacts = await FlutterContacts.getContacts(
      withProperties: true,
    );
    final Set<Contact> phoneNumbers = phoneContacts
        .where((c) => c.phones.isNotEmpty)
        .toSet();
    final prefs = await SharedPreferences.getInstance();
    final myNumber = prefs.getString("phone") ?? "";
    final nlist = List<HomeChatModel>.from([]);
    for (var u in list) {
      if (u.receiver.phone == myNumber) {
        bool found = false;
        final user = u.sender;
        for (final c in phoneNumbers) {
          final phones = c.phones
              .map((p) => normalizeNumber(p.number.trim()))
              .toList();
          if (phones.contains(normalizeNumber(user.phone.trim()))) {
            final n = user.copyWith(name: c.displayName);
            final nu = u.copyWith(sender: n);
            nlist.add(nu);
            found = true;
            break;
          }
        }
        if (!found) {
          nlist.add(u);
        }
      } else {
        bool found = false;
        final user = u.receiver;
        for (final c in phoneNumbers) {
          final phones = c.phones
              .map((p) => normalizeNumber(p.number.trim()))
              .toList();
          if (phones.contains(normalizeNumber(user.phone.trim()))) {
            final n = user.copyWith(name: c.displayName);
            final nu = u.copyWith(receiver: n);
            nlist.add(nu);
            found = true;
            break;
          }
        }
        if (!found) {
          nlist.add(u);
        }
      }
    }
    return nlist;
  }
}
