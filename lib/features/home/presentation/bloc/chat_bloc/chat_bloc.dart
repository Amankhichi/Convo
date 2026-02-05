import 'package:bloc/bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/domain_usecase/contact_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // final UserModel;
  final ContactUsecase _contactUsecase;

  ChatBloc({
    required ContactUsecase contactusecase,

  }) : _contactUsecase = contactusecase,
  super(const ChatState()) {
    on<_ContactsLoading>(__ContactsLoading);
  }
Future<void> __ContactsLoading(
  _ContactsLoading event,
  Emitter<ChatState> emit,
) async {
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

    emit(
      state.copyWith(
        contacts: matchedContacts, // 👈 important
        contactStatus: Status.success,
      ),
    );
  } catch (e) {
    emit(state.copyWith(contactStatus: Status.error));
  }
}



}
