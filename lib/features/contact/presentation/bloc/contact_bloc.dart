import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/status.dart';
import '../../../auth/data/model/user_model.dart';
import '../../domain/usecase/contact_usecase.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactUsecase _contactUsecase;

  ContactBloc({required ContactUsecase contactusecase})
    : _contactUsecase = contactusecase,
      super(const ContactState()) {
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

        updatedContacts.add(
          user.copyWith(name: name.isNotEmpty ? name : user.phone) as UserModel,
        );
      }

      emit(
        state.copyWith(
          contacts: updatedContacts,
          contactStatus: Status.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(contactStatus: Status.error));
    }
  }
}
