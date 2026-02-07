import 'package:bloc/bloc.dart';
import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/core/di/injection.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/home/domain_usecase/chat_usecase.dart';
import 'package:convo/features/home/domain_usecase/contact_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // final UserModel;
  final ContactUsecase _contactUsecase;
  final ChatUsecase _chatUsecase;

  ChatBloc({
    required ContactUsecase contactusecase,
    required ChatUsecase chatusecase,
  }) : _contactUsecase = contactusecase,
       _chatUsecase = chatusecase,
       super(const ChatState()) {
    on<_Init>(__Init);
    on<_SendMssg>(__SendMssg);
  }
  Future<void> __Init(_Init event, Emitter<ChatState> emit) async {
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

  Future<void> __SendMssg(_SendMssg event, Emitter<ChatState> emit) async {
    emit(state.copyWith(mssgStatus: Status.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString("id");

      if (id == null) {
        emit(state.copyWith(mssgStatus: Status.error));
        showError(Injection.currentContext, "Faild Fatch user id ");
        return;
      }

      final result = await _chatUsecase(
        ChatPayload(
          senderId: id,
          receiverId: event.receiverId,
          mssg: event.mssg,
        ),
      );

      emit(state.copyWith(mssgStatus: result ? Status.success : Status.error));
    } catch (e) {
      emit(state.copyWith(mssgStatus: Status.error));
    }
  }
}
