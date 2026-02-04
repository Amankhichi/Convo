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

  if (!permission.isGranted) {
    emit(state.copyWith(contactStatus: Status.init));
    return;
  }

  try {
    final matchedContacts =await _contactUsecase();

    print('Contact loading Success: $matchedContacts');
    emit(
      state.copyWith(
        // contacts: matchedContacts,
        contactStatus: Status.success,
      ),
    );
  } catch (e) {
    print('Contact loading failed: $e');
    emit(state.copyWith(contactStatus: Status.error));
  }
}


}
