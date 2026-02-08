part of "injection.dart";

class InjectionBloc {
  // static UserBloc get userBloc => UserBloc(
  //       adduserUsecase: getIt<AddUserUsecase>(), getusercase: getIt<GetUserUsecase>(), updateusecase: getIt<UpdateUserUsecase>(),
  //     );
  static SingupBloc get singupbloc => SingupBloc(adduserusecase: getIt<AddUserUsecase>(), getuserusecase: getIt<GetUserUsecase>());

  static ChatBloc get chatbloc => ChatBloc(contactusecase: getIt<ContactUsecase>(), chatusecase: getIt<ChatUsecase>(), getmssgusecase: getIt<GetMssgUseCase>());

}
