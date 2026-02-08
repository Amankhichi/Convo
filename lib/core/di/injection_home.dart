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

  getIt.registerLazySingleton<ContactUsecase>(
    () => ContactUsecase(datasource: getIt<UserDatasource>()),
  );
  
    getIt.registerLazySingleton<ChatUsecase>(
    () => ChatUsecase(datasource: getIt<UserDatasource>()),
  );

    final chatDatasource = ChatDatasource();
  getIt.registerLazySingleton<ChatDatasource>(() => chatDatasource);

  getIt.registerLazySingleton<GetMssgUseCase>(
    () => GetMssgUseCase(datasource: getIt<ChatDatasource>()),
  );
  
  
}
