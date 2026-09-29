import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:convo/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:convo/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:convo/features/contacts/domain/entities/contact_entity.dart';
import 'package:convo/features/contacts/domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDataSource _remoteDataSource;
  final ContactsLocalDataSource _localDataSource;

  ContactsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ContactEntity>> syncContacts({
    List<Map<String, dynamic>>? contacts,
    List<String>? phoneNumbers,
  }) async {
    List<Map<String, dynamic>> finalContacts = contacts ?? [];
    List<String> finalPhoneNumbers = phoneNumbers ?? [];

    if (finalContacts.isEmpty && finalPhoneNumbers.isEmpty) {
      try {
        final permissionStatus = await Permission.contacts.request();
        if (permissionStatus.isGranted) {
          final deviceContacts = await FlutterContacts.getContacts(
            withProperties: true,
            withPhoto: false,
          );

          for (var c in deviceContacts) {
            for (var p in c.phones) {
              final rawNumber = p.number.replaceAll(RegExp(r'\D'), '');
              if (rawNumber.isNotEmpty) {
                final cleanedPhone = rawNumber.length >= 10
                    ? rawNumber.substring(rawNumber.length - 10)
                    : rawNumber;

                finalPhoneNumbers.add(cleanedPhone);
                finalContacts.add({
                  "name": c.displayName.isNotEmpty ? c.displayName : "Contact",
                  "countryCode": "+91",
                  "phoneNumber": cleanedPhone,
                  "about": "Hey there! I am using ConVo.",
                  "status": "ONLINE",
                  "lastSeen": "Just now",
                  "online": true,
                });
              }
            }
          }
        }
      } catch (_) {}

      // Fallback default phone numbers if device list is empty
      if (finalPhoneNumbers.isEmpty) {
        finalPhoneNumbers = ["8595626824", "9910719882", "9876543210"];
        finalContacts = [
          {
            "name": "convo",
            "countryCode": "+91",
            "phoneNumber": "9876543210",
            "about": "Hey there! I am using ConVo.",
            "status": "ONLINE",
            "lastSeen": "11:35 pm",
            "online": true
          }
        ];
      }
    }

    final remoteContacts = await _remoteDataSource.syncContacts(
      contacts: finalContacts,
      phoneNumbers: finalPhoneNumbers,
    );

    // Save fetched data into local storage
    await _localDataSource.saveContacts(remoteContacts);

    return remoteContacts;
  }

  @override
  List<ContactEntity> getCachedContacts() {
    return _localDataSource.getCachedContacts();
  }
}
