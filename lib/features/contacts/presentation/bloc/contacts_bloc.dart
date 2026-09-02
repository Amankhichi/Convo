import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsBloc(this._contactsRepository) : super(ContactsInitial()) {
    on<SyncContactsEvent>(_onSyncContacts);
    on<LoadCachedContactsEvent>(_onLoadCachedContacts);
  }

  Future<void> _onSyncContacts(
    SyncContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    final cached = _contactsRepository.getCachedContacts();
    if (cached.isNotEmpty) {
      emit(ContactsLoaded(cached));
    } else {
      emit(ContactsLoading());
    }

    try {
      final synced = await _contactsRepository.syncContacts(
        contacts: event.contacts,
        phoneNumbers: event.phoneNumbers,
      );
      emit(ContactsLoaded(synced));
    } catch (e) {
      if (cached.isNotEmpty) {
        emit(ContactsLoaded(cached));
      } else {
        emit(ContactsError(e.toString()));
      }
    }
  }

  void _onLoadCachedContacts(
    LoadCachedContactsEvent event,
    Emitter<ContactsState> emit,
  ) {
    final cached = _contactsRepository.getCachedContacts();
    emit(ContactsLoaded(cached));
  }
}
