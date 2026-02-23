part of "injection.dart";

Future<void> __homeDependency() async {
  final userDatasource = UserDatasource();
  getIt.registerLazySingleton<UserDatasource>(() => userDatasource);

  getIt.registerLazySingleton<AddUserUsecase>(
    () => AddUserUsecase(datasource: getIt<UserDatasource>()),
  );

    getIt.registerLazySingleton<GetUserUsecase>(
    () => GetUserUsecase(datasource: getIt<UserDatasource>()),
  );

  // getIt.registerLazySingleton<ContactUsecase>(
  //   () => ContactUsecase(datasource: getIt<UserDatasource>()),
  // );
  
    getIt.registerLazySingleton<SendMssgUsecase>(
    () => SendMssgUsecase(datasource: getIt<ChatDatasource>()),
  );

    final chatDatasource = ChatDatasource();
  getIt.registerLazySingleton<ChatDatasource>(() => chatDatasource);

  getIt.registerLazySingleton<GetMssgUseCase>(
    () => GetMssgUseCase(datasource: getIt<ChatDatasource>()),
  );

    getIt.registerLazySingleton<DeletMssgUsecase>(
    () => DeletMssgUsecase(datasource: getIt<ChatDatasource>()),
  );

  getIt.registerLazySingleton<EditMessageUseCase>(
    () => EditMessageUseCase(datasource: getIt<ChatDatasource>()),
  );

    getIt.registerLazySingleton<GetMssgUseCase>(
    () => GetMssgUseCase(datasource: getIt<ChatDatasource>()),
  );
  
  
}
