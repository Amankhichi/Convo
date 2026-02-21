part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.init() = _Init;
  const factory LoginEvent.phone(String value) = _Phone;
  const factory LoginEvent.name(String value) = _Name;
  const factory LoginEvent.nickName(String value) = _NickName;
  const factory LoginEvent.about(String value) = _About;
  const factory LoginEvent.lotti(String value) = _Lotti;
  const factory LoginEvent.online(bool value) = _Online;
  const factory LoginEvent.add() = _Add;
  const factory LoginEvent.checkNumber() = _CheckNumber;
  const factory LoginEvent.checkUser() = _CheckUser;
}