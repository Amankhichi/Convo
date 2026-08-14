part of 'login_bloc.dart';

abstract class LoginEvent {
  const factory LoginEvent.init() = _Init;
  const factory LoginEvent.phone(String value) = _Phone;
  const factory LoginEvent.name(String value) = _Name;
  const factory LoginEvent.nickName(String value) = _NickName;
  const factory LoginEvent.about(String value) = _About;
  const factory LoginEvent.lotti(String value) = _Lotti;
  const factory LoginEvent.online(bool value) = _Online;
  const factory LoginEvent.add() = _Add;
  const factory LoginEvent.sendOtp() = _SendOtp;
  const factory LoginEvent.verifyOtp({
    required String otp,
    required String countryCode,
    required String mobileNumber,
  }) = _VerifyOtp;
  const factory LoginEvent.checkNumber() = _CheckNumber;
  const factory LoginEvent.checkUser() = _CheckUser;
  const factory LoginEvent.setOnline({
    required int userId,
    required bool online,
  }) = _SetOnline;
}

class _Init implements LoginEvent {
  const _Init();
}

class _Phone implements LoginEvent {
  final String value;
  const _Phone(this.value);
}

class _Name implements LoginEvent {
  final String value;
  const _Name(this.value);
}

class _NickName implements LoginEvent {
  final String value;
  const _NickName(this.value);
}

class _About implements LoginEvent {
  final String value;
  const _About(this.value);
}

class _Lotti implements LoginEvent {
  final String value;
  const _Lotti(this.value);
}

class _Online implements LoginEvent {
  final bool value;
  const _Online(this.value);
}

class _Add implements LoginEvent {
  const _Add();
}

class _SendOtp implements LoginEvent {
  const _SendOtp();
}

class _VerifyOtp implements LoginEvent {
  final String otp;
  final String countryCode;
  final String mobileNumber;

  const _VerifyOtp({
    required this.otp,
    required this.countryCode,
    required this.mobileNumber,
  });
}

class _CheckNumber implements LoginEvent {
  const _CheckNumber();
}

class _CheckUser implements LoginEvent {
  const _CheckUser();
}

class _SetOnline implements LoginEvent {
  final int userId;
  final bool online;
  const _SetOnline({required this.userId, required this.online});
}

class RequestOtpEvent implements LoginEvent {
  final String countryCode;
  final String mobileNumber;

  const RequestOtpEvent({
    required this.countryCode,
    required this.mobileNumber,
  });
}

