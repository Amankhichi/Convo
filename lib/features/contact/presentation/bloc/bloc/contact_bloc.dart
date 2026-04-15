import 'package:bloc/bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/contact/domain_usecase/contact_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'contact_event.dart';
part 'contact_state.dart';
part 'contact_bloc.freezed.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactUsecase _contactUsecase;

  ContactBloc({
    required ContactUsecase contactusecase,
    })
    : _contactUsecase = contactusecase,
      super(ContactState()) {
    on<_Init>(__Init);
  }
Future<void> __Init(_Init event, Emitter<ContactState> emit) async {
  emit(state.copyWith(contactStatus: Status.loading));

  final permission = await Permission.contacts.request();

  if (permission.isPermanentlyDenied) {
    emit(state.copyWith(contactStatus: Status.error));
    return;
  }

  if (!permission.isGranted) {
    emit(state.copyWith(contactStatus: Status.error));
    return;
  }

  try {
    final matchedContacts = await _contactUsecase();

    final List<UserModel> updatedContacts = [];

    for (final user in matchedContacts) {
      final name = await nameInPhone(user.phone);

      updatedContacts.add(user.copyWith(name: name.isNotEmpty ? name : user.phone,
        ),
      );
    }

    emit(
      state.copyWith(
        contacts: updatedContacts,
        contactStatus: Status.success,
      ),
    );
    print("updatedContacts ${state.contacts}");
  } catch (e) {
    emit(state.copyWith(contactStatus: Status.error));
  }
}
}
