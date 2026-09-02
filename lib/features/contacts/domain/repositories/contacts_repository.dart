import 'package:convo/features/contacts/domain/entities/contact_entity.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> syncContacts({
    List<Map<String, dynamic>>? contacts,
    List<String>? phoneNumbers,
  });

  List<ContactEntity> getCachedContacts();
}
