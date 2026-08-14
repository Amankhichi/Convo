import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/snackbar_widgets.dart';
import '../../../../core/utils/status.dart';
import '../../domain/entity/chat_entity.dart';
import '../../data/payload/chat_payload.dart';
import '../../data/model/chat_model.dart';
import '../../domain/usecase/send_message_usecase.dart';
import '../../domain/usecase/get_messages_usecase.dart';
import '../../domain/usecase/delete_message_usecase.dart';
import '../../domain/usecase/edit_message_usecase.dart';
import '../../domain/usecase/seen_message_usecase.dart';
import '../../../auth/presentation/bloc/login_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

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
        showError(Injection.currentContext, "Failed Fetch user id");
        return;
      }

      final result = await _sendMssgUsecase(
        ChatPayload(
          senderId: int.tryParse(id.toString()) ?? 0,
          receiverId: int.tryParse(event.receiverId) ?? 0,
          massage: event.mssg,
          replyTo: int.tryParse(event.replyTo.toString()) ?? 0,
          seen: false,
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

  Future<void> __GetMssg(_GetMssg e, Emitter<ChatState> emit) async {
    emit(state.copyWith(GetMssgStatus: Status.loading));

    final profile =
        Injection.currentContext.read<LoginBloc>().state.profile;

    if (profile == null) {
      emit(state.copyWith(GetMssgStatus: Status.error));
      return;
    }

    try {
      final msgs = await _getmssgusecase(
        senderId: profile.id.toString(),
        receiverId: e.receiverId,
      );

      emit(state.copyWith(
        GetMssgStatus: Status.success,
        messages: List.from(msgs),
      ));

      final r = int.tryParse(e.receiverId);
      if (r != null) add(ChatEvent.seen(sender: r));
    } catch (e) {
      print("❌ Bloc Error: $e");
      emit(state.copyWith(GetMssgStatus: Status.error));
    }
  }

  Future<void> __DeletMssg(_DeletMssg event, Emitter<ChatState> emit) async {
    emit(state.copyWith(DeleteMssgStatus: Status.loading));

    final success = await _deletMssgUsecase(mssgId: event.mssId);

    if (success) {
      add(_Init());
      emit(state.copyWith(DeleteMssgStatus: Status.success));

      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(DeleteMssgStatus: Status.init));
    } else {
      emit(state.copyWith(DeleteMssgStatus: Status.error));
    }
  }

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

    if (id == null) return;

    await _seenMssgUsecase(receiverId: int.parse(id), senderId: event.sender);
  }
}
