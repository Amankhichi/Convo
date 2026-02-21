part of "injection.dart";

class InjectionBloc {
  
  static SingupBloc get singupbloc => SingupBloc(
    adduserusecase: getIt<AddUserUsecase>(),
    getuserusecase: getIt<GetUserUsecase>(),
  );

  static ChatBloc get chatbloc => ChatBloc(
    contactusecase: getIt<ContactUsecase>(),
    chatusecase: getIt<ChatUsecase>(),
    getmssgusecase: getIt<GetMssgUseCase>(),
    deletmssgusecase: getIt<DeletMssgUsecase>(),
    editmessageusecase: getIt<EditMessageUseCase>(),
  );
}
