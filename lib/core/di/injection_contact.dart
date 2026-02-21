part of "injection.dart";



Future<void> __contactDependency() async {
  final contactDatasource = ContactDatasource();
  getIt.registerLazySingleton<ContactDatasource>(() => contactDatasource);

  
  getIt.registerLazySingleton<ContactUsecase>(
    () => ContactUsecase(datasource: getIt<ContactDatasource>()),
  );
  
  
}
