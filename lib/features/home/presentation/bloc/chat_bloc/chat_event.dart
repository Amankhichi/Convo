part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.init() = _Init;
  const factory ChatEvent.sendMssg({ 
    required String mssg,
    required String receiverId,
    }) = _SendMssg;
  const factory ChatEvent.getMssg({
    required String receiverId,
  }) = _GetMssg;



}