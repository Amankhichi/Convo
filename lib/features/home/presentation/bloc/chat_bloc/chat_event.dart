part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.init() = _Init;
  const factory ChatEvent.contactsLoading() = _ContactsLoading;
  const factory ChatEvent.sendMssg({ 
    required String mssg,
    // required String sendID,
    required String receiverId,
    }) = _SendMssg;


}