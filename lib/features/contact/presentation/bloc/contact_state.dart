part of 'contact_bloc.dart';

class ContactState {
  final Status contactStatus;
  final List<UserModel> contacts;

  const ContactState({
    this.contactStatus = Status.init,
    this.contacts = const [],
  });

  factory ContactState.initial() => const ContactState(
        contactStatus: Status.init,
        contacts: [],
      );

  ContactState copyWith({
    Status? contactStatus,
    List<UserModel>? contacts,
  }) {
    return ContactState(
      contactStatus: contactStatus ?? this.contactStatus,
      contacts: contacts ?? this.contacts,
    );
  }
}
