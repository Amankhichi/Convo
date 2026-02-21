part of "injection.dart";



Future<void> __contactDependency() async {
  // Datasource
  final contactDatasource = ContactDatasource();
  getIt.registerLazySingleton<ContactDatasource>(() => contactDatasource);

  // usecase
  getIt.registerLazySingleton<ContactUsecase>(
    () => ContactUsecase(datasource: getIt<ContactDatasource>()),
  );
  
  
}
