part of 'singup_bloc.dart';

@freezed
class SingupEvent with _$SingupEvent {
  const factory SingupEvent.init() = _Init;
  const factory SingupEvent.phone(String value) = _Phone;
  const factory SingupEvent.name(String value) = _Name;
  const factory SingupEvent.nickName(String value) = _NickName;
  const factory SingupEvent.about(String value) = _About;
  const factory SingupEvent.lotti(String value) = _Lotti;
  const factory SingupEvent.online(bool value) = _Online;
  const factory SingupEvent.add() = _Add;
  const factory SingupEvent.checkNumber() = _CheckNumber;
  const factory SingupEvent.checkUser() = _CheckUser;

}