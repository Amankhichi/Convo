part of 'singup_bloc.dart';

@freezed
class SingupState with _$SingupState {
  const factory SingupState({
    @Default(Status.init) Status adduserStatus,
    @Default(Status.init) Status checkuserStatus,
    @Default(Status.init) Status checkNumberStatus,
    @Default(null) UserModel? profile,
    @Default("") String phone,
    @Default("") String name,
    @Default("") String nickName,
    @Default("") String about,
    @Default("") String lotti,
    @Default(false) bool online,
  }) = _SingupState;
}
