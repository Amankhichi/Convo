part of "injection.dart";

class InjectionBloc {

  static LoginBloc get loginbloc => LoginBloc(
    adduserusecase: getIt<AddUserUsecase>(),
    getuserusecase: getIt<GetUserUsecase>(),
  );

  static ChatBloc get chatbloc => ChatBloc(
    sendmssgusecase: getIt<SendMssgUsecase>(),
    getmssgusecase: getIt<GetMssgUseCase>(),
    deletmssgusecase: getIt<DeletMssgUsecase>(),
    editmessageusecase: getIt<EditMessageUseCase>(),
  );


    static ContactBloc get contactbloc => ContactBloc(
    contactusecase: getIt<ContactUsecase>(),
  );

  static HomeBloc get homebloc => HomeBloc(getchatsusecase: getIt<GetChatsUseCase>(),
  );

}
