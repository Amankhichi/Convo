part of "injection.dart";

Future<void> __homeDependency() async {

  /// 🔹 DATASOURCES FIRST
  getIt.registerLazySingleton<UserDatasource>(
    () => UserDatasource(),
  );

  getIt.registerLazySingleton<ChatDatasource>(
    () => ChatDatasource(),
  );

    getIt.registerLazySingleton<LoginDatasource>(
    () => LoginDatasource(),
  );

  /// 🔹 USER USECASES
  getIt.registerLazySingleton<AddUserUsecase>(
    () => AddUserUsecase(datasource: getIt<UserDatasource>()),
  );

  getIt.registerLazySingleton<GetHomeChatsListUsecase>(
    () => GetHomeChatsListUsecase(datasource: getIt<UserDatasource>()),
  );

  getIt.registerLazySingleton<GetUserUsecase>(
    () => GetUserUsecase(datasource: getIt<UserDatasource>()),
  );

  /// 🔹 CHAT USECASES
  getIt.registerLazySingleton<SendMssgUsecase>(
    () => SendMssgUsecase(datasource: getIt<ChatDatasource>()),
  );

  getIt.registerLazySingleton<GetMssgUseCase>(
    () => GetMssgUseCase(datasource: getIt<ChatDatasource>()),
  );

  getIt.registerLazySingleton<DeletMssgUsecase>(
    () => DeletMssgUsecase(datasource: getIt<ChatDatasource>()),
  );

  getIt.registerLazySingleton<EditMessageUseCase>(
    () => EditMessageUseCase(datasource: getIt<ChatDatasource>()),
  );

    getIt.registerLazySingleton<SeenMssgUsecase>(
    () => SeenMssgUsecase(datasource: getIt<ChatDatasource>()),
  );
}