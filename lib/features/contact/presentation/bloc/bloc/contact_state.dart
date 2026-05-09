part of 'contact_bloc.dart';

@freezed
class ContactState with _$ContactState {
  const factory ContactState({
    @Default([]) List<UserModel> contacts,
    @Default(Status.init) Status contactStatus,
  }) = _ContactState;
}
