import 'package:convo/app/localization/language_manager.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:convo/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';
import 'package:convo/features/authentication/domain/usecases/delete_account_usecase.dart';
import 'package:convo/features/authentication/domain/usecases/request_otp_usecase.dart';
import 'package:convo/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:convo/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:convo/features/contacts/data/datasources/contacts_remote_datasource.dart';
import 'package:convo/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:convo/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:convo/features/contacts/presentation/bloc/contacts_bloc.dart';

import 'package:convo/features/chats/data/datasources/chat_local_datasource.dart';
import 'package:convo/features/chats/data/datasources/chat_remote_datasource.dart';
import 'package:convo/features/chats/data/repositories/chat_repository_impl.dart';
import 'package:convo/features/chats/domain/repositories/chat_repository.dart';
import 'package:convo/features/chats/presentation/bloc/chat_bloc.dart';

import 'package:convo/core/network/stomp_service.dart';
import 'package:convo/core/network/chat_realtime_service.dart';
import 'package:convo/features/home/data/datasources/home_local_datasource.dart';
import 'package:convo/features/home/data/datasources/home_remote_datasource.dart';
import 'package:convo/features/home/data/repositories/home_repository_impl.dart';
import 'package:convo/features/home/domain/repositories/home_repository.dart';
import 'package:convo/features/home/presentation/bloc/home_bloc.dart';
import 'package:convo/features/stories/data/repositories/story_repository_impl.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/features/calling/data/repositories/call_repository_impl.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';

import 'package:convo/core/presence/presence_manager.dart';
import 'package:convo/features/presence/data/datasources/presence_remote_datasource.dart';
import 'package:convo/features/presence/data/repositories/presence_repository_impl.dart';
import 'package:convo/features/presence/domain/repositories/presence_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // 1. External & Core Storage
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));

  // 2. Localization
  sl.registerLazySingleton<LanguageManager>(() => LanguageManager());

  // 3. Network, Realtime WebSockets & Global Presence
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));
  sl.registerLazySingleton<StompService>(() => StompService(sl()));
  sl.registerLazySingleton<ChatRealtimeService>(
    () => ChatRealtimeService(sl(), sl()),
  );

  // 3b. Presence Feature & Heartbeat Engine
  sl.registerLazySingleton<PresenceRemoteDataSource>(
    () => PresenceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PresenceRepository>(
    () => PresenceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PresenceManager>(
    () => PresenceManager(sl()),
  );

  // 4. Auth Feature Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // 5. Auth UseCases
  sl.registerLazySingleton<RequestOtpUseCase>(() => RequestOtpUseCase(sl()));
  sl.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton<DeleteAccountUseCase>(() => DeleteAccountUseCase(sl()));

  // 6. Contacts Feature Data & Repository
  sl.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ContactsLocalDataSource>(
    () => ContactsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(sl(), sl()),
  );

  // 7. Chat Feature Data & Repository
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl(), sl()),
  );

  // 8. Home Feature Data & Repository
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl(), sl()),
  );

  // 8b. Stories & Call History Repositories
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(sl()),
  );

  // 9. BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      requestOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
      deleteAccountUseCase: sl(),
      localStorage: sl(),
    ),
  );

  sl.registerFactory<ContactsBloc>(
    () => ContactsBloc(sl()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      chatRepository: sl(),
      realtimeService: sl(),
    ),
  );

  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      homeRepository: sl(),
      realtimeService: sl(),
    ),
  );
}
