part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.init() = _Init;
  const factory ChatEvent.sendMssg({ 
    required String mssg,
    required String receiverId,
    required int? replyTo,
    }) = _SendMssg;
  const factory ChatEvent.getMssg({
    required String receiverId,
  }) = _GetMssg;
  const factory ChatEvent.seen({required int sender}) = _Seen;
  const factory ChatEvent.deletMssg({required int mssId}) = _DeletMssg;
  const factory ChatEvent.blockButton({required bool block}) = _BlockButton;
  const factory ChatEvent.editMssg({required int mssgId,required String newMssg}) = _EditMssg;


}