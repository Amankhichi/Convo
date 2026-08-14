part of 'login_bloc.dart';

class LoginState {
  final Status adduserStatus;
  final Status checkuserStatus;
  final Status checkNumberStatus;
  final Status sendOtpStatus;
  final Status verifyOtpStatus;
  final UserEntity? profile;
  final String phone;
  final String name;
  final String nickName;
  final String about;
  final String lotti;
  final bool online;

  const LoginState({
    this.adduserStatus = Status.init,
    this.checkuserStatus = Status.init,
    this.checkNumberStatus = Status.init,
    this.sendOtpStatus = Status.init,
    this.verifyOtpStatus = Status.init,
    this.profile,
    this.phone = "",
    this.name = "",
    this.nickName = "",
    this.about = "",
    this.lotti = "",
    this.online = false,
  });

  LoginState copyWith({
    Status? adduserStatus,
    Status? checkuserStatus,
    Status? checkNumberStatus,
    Status? sendOtpStatus,
    Status? verifyOtpStatus,
    UserEntity? profile,
    String? phone,
    String? name,
    String? nickName,
    String? about,
    String? lotti,
    bool? online,
  }) {
    return LoginState(
      adduserStatus: adduserStatus ?? this.adduserStatus,
      checkuserStatus: checkuserStatus ?? this.checkuserStatus,
      checkNumberStatus: checkNumberStatus ?? this.checkNumberStatus,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      verifyOtpStatus: verifyOtpStatus ?? this.verifyOtpStatus,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      about: about ?? this.about,
      lotti: lotti ?? this.lotti,
      online: online ?? this.online,
    );
  }
}

class RequestOtpInitial extends LoginState {
  const RequestOtpInitial({
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class RequestOtpLoading extends LoginState {
  const RequestOtpLoading({
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class RequestOtpSuccess extends LoginState {
  final RequestOtpResponse response;

  const RequestOtpSuccess({
    required this.response,
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class RequestOtpFailure extends LoginState {
  final String message;

  const RequestOtpFailure({
    required this.message,
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class VerifyOtpLoading extends LoginState {
  const VerifyOtpLoading({
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class VerifyOtpSuccess extends LoginState {
  final bool success;
  final bool newUser;
  final String? token;
  final UserEntity? user;

  const VerifyOtpSuccess({
    required this.success,
    required this.newUser,
    this.token,
    this.user,
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

class VerifyOtpFailure extends LoginState {
  final String message;

  const VerifyOtpFailure({
    required this.message,
    super.phone,
    super.name,
    super.nickName,
    super.about,
    super.lotti,
    super.online,
  });
}

