import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../services/file_upload_service.dart';
import '../firebase/firebase_services.dart';

// Features - Auth
import '../../features/auth/data/datasource/remote/auth_remote_datasource.dart';
import '../../features/auth/data/datasource/remote/login_remote_datasource.dart';
import '../../features/auth/data/datasource/local/auth_local_datasource.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/repository/login_repository.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/data/repository/login_repository_impl.dart';
import '../../features/auth/domain/usecase/send_otp_usecase.dart';
import '../../features/auth/domain/usecase/verify_otp_usecase.dart';
import '../../features/auth/domain/usecase/complete_profile_usecase.dart';
import '../../features/auth/domain/usecase/get_user_usecase.dart';
import '../../features/auth/domain/usecase/update_user_usecase.dart';
import '../../features/auth/domain/usecase/add_user_usecase.dart';
import '../../features/auth/domain/usecase/request_otp_usecase.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';

// Features - Chat
import '../../features/chat/data/datasource/remote/chat_remote_datasource.dart';
import '../../features/chat/domain/repository/chat_repository.dart';
import '../../features/chat/data/repository/chat_repository_impl.dart';
import '../../features/chat/domain/usecase/send_message_usecase.dart';
import '../../features/chat/domain/usecase/get_messages_usecase.dart';
import '../../features/chat/domain/usecase/delete_message_usecase.dart';
import '../../features/chat/domain/usecase/edit_message_usecase.dart';
import '../../features/chat/domain/usecase/seen_message_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

// Features - Contact
import '../../features/contact/data/datasource/remote/contact_remote_datasource.dart';
import '../../features/contact/domain/repository/contact_repository.dart';
import '../../features/contact/data/repository/contact_repository_impl.dart';
import '../../features/contact/domain/usecase/contact_usecase.dart';
import '../../features/contact/presentation/bloc/contact_bloc.dart';

// Features - Home
import '../../features/home/data/datasource/remote/home_remote_datasource.dart';
import '../../features/home/domain/repository/home_repository.dart';
import '../../features/home/data/repository/home_repository_impl.dart';
import '../../features/home/domain/usecase/get_home_chats_list_usecase.dart';
import '../../features/home/domain/usecase/update_online_status_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // 🔹 SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
    getIt.registerLazySingleton<SharedPreferencesWrapper>(
        () => SharedPreferencesWrapper(getIt<SharedPreferences>()));

    // 🔹 SecureStorage & Hive
    getIt.registerLazySingleton<SecureStorageWrapper>(() => SecureStorageWrapper());
    getIt.registerLazySingleton<HiveStorageWrapper>(() => HiveStorageWrapper());

    // 🔹 ApiClient
    getIt.registerLazySingleton<ApiClient>(() => ApiClient(secureStorage: getIt<SecureStorageWrapper>()));

    // 🔹 Services
    getIt.registerLazySingleton<FileUploadService>(() => FileUploadService(getIt<ApiClient>()));

    // 🔹 Firebase Services
    getIt.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
    getIt.registerLazySingleton<FirebaseMessagingService>(() => FirebaseMessagingService());
    getIt.registerLazySingleton<FirebaseCrashlyticsService>(() => FirebaseCrashlyticsService());
    getIt.registerLazySingleton<FirebaseAnalyticsService>(() => FirebaseAnalyticsService());
    getIt.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());
    getIt.registerLazySingleton<FirebaseFirestoreService>(() => FirebaseFirestoreService());

    // 🔹 Auth Feature DI
    getIt.registerLazySingleton<AuthRemoteDatasource>(
        () => AuthRemoteDatasourceImpl(getIt<ApiClient>()));
    getIt.registerLazySingleton<LoginRemoteDataSource>(
        () => LoginRemoteDataSourceImpl(getIt<ApiClient>()));
    getIt.registerLazySingleton<AuthLocalDatasource>(
        () => AuthLocalDatasourceImpl(getIt<SharedPreferencesWrapper>(), getIt<SecureStorageWrapper>()));
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
          remoteDatasource: getIt<AuthRemoteDatasource>(),
          localDatasource: getIt<AuthLocalDatasource>(),
        ));
    getIt.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(
          remoteDataSource: getIt<LoginRemoteDataSource>(),
        ));
    getIt.registerLazySingleton<SendOtpUseCase>(() => SendOtpUseCase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<CompleteProfileUseCase>(
        () => CompleteProfileUseCase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<GetUserUsecase>(() => GetUserUsecase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<UpdateUserUsecase>(() => UpdateUserUsecase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<AddUserUsecase>(() => AddUserUsecase(repository: getIt<AuthRepository>()));
    getIt.registerLazySingleton<RequestOtpUseCase>(
        () => RequestOtpUseCase(repository: getIt<LoginRepository>()));
    getIt.registerFactory<LoginBloc>(() => LoginBloc(
          completeProfileUseCase: getIt<CompleteProfileUseCase>(),
          getuserusecase: getIt<GetUserUsecase>(),
          updateonlinestatususecase: getIt<UpdateOnlineStatusUseCase>(),
          sendOtpUseCase: getIt<SendOtpUseCase>(),
          verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
          requestOtpUseCase: getIt<RequestOtpUseCase>(),
        ));

    // 🔹 Chat Feature DI
    getIt.registerLazySingleton<ChatRemoteDatasource>(
        () => ChatRemoteDatasourceImpl(getIt<ApiClient>()));
    getIt.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(remoteDatasource: getIt<ChatRemoteDatasource>()));
    getIt.registerLazySingleton<SendMssgUsecase>(() => SendMssgUsecase(repository: getIt<ChatRepository>()));
    getIt.registerLazySingleton<GetMssgUseCase>(() => GetMssgUseCase(repository: getIt<ChatRepository>()));
    getIt.registerLazySingleton<DeletMssgUsecase>(() => DeletMssgUsecase(repository: getIt<ChatRepository>()));
    getIt.registerLazySingleton<EditMessageUseCase>(() => EditMessageUseCase(repository: getIt<ChatRepository>()));
    getIt.registerLazySingleton<SeenMssgUsecase>(() => SeenMssgUsecase(repository: getIt<ChatRepository>()));
    getIt.registerFactory<ChatBloc>(() => ChatBloc(
          seenmssgusecase: getIt<SeenMssgUsecase>(),
          sendmssgusecase: getIt<SendMssgUsecase>(),
          getmssgusecase: getIt<GetMssgUseCase>(),
          deletmssgusecase: getIt<DeletMssgUsecase>(),
          editmessageusecase: getIt<EditMessageUseCase>(),
        ));

    // 🔹 Contact Feature DI
    getIt.registerLazySingleton<ContactRemoteDatasource>(
        () => ContactRemoteDatasourceImpl(getIt<ApiClient>()));
    getIt.registerLazySingleton<ContactRepository>(
        () => ContactRepositoryImpl(remoteDatasource: getIt<ContactRemoteDatasource>()));
    getIt.registerLazySingleton<ContactUsecase>(() => ContactUsecase(repository: getIt<ContactRepository>()));
    getIt.registerFactory<ContactBloc>(() => ContactBloc(contactusecase: getIt<ContactUsecase>()));

    // 🔹 Home Feature DI
    getIt.registerLazySingleton<HomeRemoteDatasource>(
        () => HomeRemoteDatasourceImpl(getIt<ApiClient>()));
    getIt.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(remoteDatasource: getIt<HomeRemoteDatasource>()));
    getIt.registerLazySingleton<GetHomeChatsListUsecase>(
        () => GetHomeChatsListUsecase(repository: getIt<HomeRepository>()));
    getIt.registerLazySingleton<UpdateOnlineStatusUseCase>(
        () => UpdateOnlineStatusUseCase(getIt<HomeRepository>()));
    getIt.registerFactory<HomeBloc>(() => HomeBloc(gethomechatslistusecase: getIt<GetHomeChatsListUsecase>()));
  }
}
