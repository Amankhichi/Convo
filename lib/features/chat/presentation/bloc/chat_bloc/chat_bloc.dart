import 'package:bloc/bloc.dart';
import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/core/di/injection.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/chat_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/chat/domain_usecase/delet_mssg_usecase.dart';
import 'package:convo/features/chat/domain_usecase/edit_meesage_usecase.dart';
import 'package:convo/features/chat/domain_usecase/get_mssg_usecase.dart';
import 'package:convo/features/chat/domain_usecase/seen_mssg_usecase.dart';
import 'package:convo/features/chat/domain_usecase/send_mssg_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SeenMssgUsecase _seenMssgUsecase;
  final SendMssgUsecase _sendMssgUsecase;
  final GetMssgUseCase _getmssgusecase;
  final DeletMssgUsecase _deletMssgUsecase;
  final EditMessageUseCase _editMessageUseCase;

  ChatBloc({
    required SeenMssgUsecase seenmssgusecase,
    required SendMssgUsecase sendmssgusecase,
    required GetMssgUseCase getmssgusecase,
    required DeletMssgUsecase deletmssgusecase,
    required EditMessageUseCase editmessageusecase,
  }) : _seenMssgUsecase = seenmssgusecase,
       _sendMssgUsecase = sendmssgusecase,
       _getmssgusecase = getmssgusecase,
       _deletMssgUsecase = deletmssgusecase,
       _editMessageUseCase = editmessageusecase,
       super(const ChatState()) {
    on<_Init>(__Init);
    on<_EditMssg>(__EditMssg);
    on<_SendMssg>(__SendMssg);
    on<_GetMssg>(__GetMssg);
    on<_DeletMssg>(__DeletMssg);
    on<_Seen>(__Seen);
  }
  Future<void> __Init(_Init event, Emitter<ChatState> emit) async {}

  Future<void> __SendMssg(_SendMssg event, Emitter<ChatState> emit) async {
    emit(state.copyWith(SendMssgStatus: Status.loading));
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("id");

    try {
      if (id.toString().isEmpty) {
        emit(state.copyWith(SendMssgStatus: Status.error));
        showError(Injection.currentContext, "Faild Fatch user id ");
        return;
      }

      final result = await _sendMssgUsecase(
        ChatPayload(
          senderId: int.tryParse(id.toString()) ?? 0,
          receiverId: int.tryParse(event.receiverId) ?? 0,
          mssg: event.mssg,
          replyTo: event.replyTo,
        ),
      );
      emit(
        state.copyWith(SendMssgStatus: result ? Status.success : Status.error),
      );
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ChatModel(
              id: 0,
              seen: false,
              senderId: int.tryParse(id.toString()) ?? 0,
              receiverId: int.tryParse(event.receiverId) ?? 0,
              message: event.mssg,
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );
      add(_GetMssg(receiverId: event.receiverId));
    } catch (e) {
      emit(state.copyWith(SendMssgStatus: Status.error));
    }
  }

  Future<void> __GetMssg(_GetMssg event, Emitter<ChatState> emit) async {
    emit(state.copyWith(GetMssgStatus: Status.loading));
    int l = state.messages.length;
    final profile = Injection.currentContext.read<LoginBloc>().state.profile;
    if (profile == null) {
      emit(state.copyWith(GetMssgStatus: Status.error));
      return;
    }
    try {
      final messagess = await _getmssgusecase(
        senderId: profile.id.toString(),
        receiverId: event.receiverId,
      );

      emit(state.copyWith(GetMssgStatus: Status.success, messages: messagess));

      add(ChatEvent.seen(sender: int.parse(event.receiverId)));
    } catch (e) {
      emit(state.copyWith(GetMssgStatus: Status.error));
      emit(state.copyWith(GetMssgStatus: Status.init));
    }
  }

  Future<void> __DeletMssg(_DeletMssg event, Emitter<ChatState> emit) async {
    emit(state.copyWith(DeleteMssgStatus: Status.loading));

    final success = await _deletMssgUsecase(mssgId: event.mssId);

    if (success) {
      add(_Init());
      emit(state.copyWith(DeleteMssgStatus: Status.success));

      // reset after UI update
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(DeleteMssgStatus: Status.init));
    } else {
      emit(state.copyWith(DeleteMssgStatus: Status.error));
    }
  }

  // Future<void> __BlockButton(_BlockButton event, Emitter<ChatState> emit) async {
  //   blockUser
  // }

  Future<void> __EditMssg(_EditMssg event, Emitter<ChatState> emit) async {
    final edit = await _editMessageUseCase(
      msgId: event.mssgId,
      newMessage: event.newMssg,
    );

    if (edit) {
      print("Message Edited Successfully");
    } else {
      print("Edit Failed");
    }
  }

  Future<void> __Seen(_Seen event, Emitter<ChatState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("id");
    final seen = await _seenMssgUsecase(
      receiverId: int.parse(id.toString()),
      senderId: event.sender,
    );
  }
}
