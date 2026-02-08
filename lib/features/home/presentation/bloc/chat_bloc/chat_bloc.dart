import 'package:bloc/bloc.dart';
import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/core/di/injection.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/chat_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/auth/domain_usecase/get_mssg_usecase.dart';
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
  final GetMssgUseCase _getmssgusecase;

  ChatBloc({
    required ContactUsecase contactusecase,
    required ChatUsecase chatusecase,
    required GetMssgUseCase getmssgusecase,
  }) : _contactUsecase = contactusecase,
       _chatUsecase = chatusecase,
       _getmssgusecase = getmssgusecase,
       super(const ChatState()) {
    on<_Init>(__Init);
    on<_SendMssg>(__SendMssg);
    on<_GetMssg>(__GetMssg);

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
    emit(state.copyWith(SendMssgStatus: Status.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString("id");

      if (id == null) {
        emit(state.copyWith(SendMssgStatus: Status.error));
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

      emit(state.copyWith(SendMssgStatus: result ? Status.success : Status.error));
    } catch (e) {
      emit(state.copyWith(SendMssgStatus: Status.error));
    }
  }

   Future<void>  __GetMssg(_GetMssg event, Emitter<ChatState> emit) async {
  emit(state.copyWith(GetMssgStatus: Status.loading));

  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString("id");

  if (id == null) {
    emit(state.copyWith(GetMssgStatus: Status.error,));
    return;
  }

  try {
    final messages = await _getmssgusecase(
      senderId: id,
      receiverId: event.receiverId,
    );

    emit(state.copyWith(
      GetMssgStatus: Status.success,
      messages: messages,
    ));
  } catch (e) {
    emit(state.copyWith(
      GetMssgStatus: Status.error,
    ));
  }
}

}
