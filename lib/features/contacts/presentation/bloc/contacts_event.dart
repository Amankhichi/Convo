import 'package:equatable/equatable.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

class SyncContactsEvent extends ContactsEvent {
  final List<Map<String, dynamic>>? contacts;
  final List<String>? phoneNumbers;

  const SyncContactsEvent({this.contacts, this.phoneNumbers});

  @override
  List<Object?> get props => [contacts, phoneNumbers];
}

class LoadCachedContactsEvent extends ContactsEvent {}
