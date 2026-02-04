import 'package:convo/core/navigator_service.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';
import 'package:convo/features/home/domain_usecase/add_user_usecase.dart';
import 'package:convo/features/home/domain_usecase/contact_usecase.dart';
import 'package:convo/features/home/domain_usecase/get_user_usecase.dart';
import 'package:convo/features/home/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


part "injection_auth.dart";
part "injection_home.dart";
part "injection_bloc.dart";
final GetIt getIt = GetIt.instance;


class Injection {
  static BuildContext get currentContext {
    final ctx = navigatorState.currentContext;
    if (ctx == null) {
      throw FlutterError("Context not available");
    }
    return ctx;
  }

  static NavigationService get navigationService => getIt<NavigationService>();

  static GlobalKey<NavigatorState> get navigatorState =>
      getIt<NavigationService>().navigatorkey;

  static Future<void> initialDependency() async {
    final navigationService = NavigationService();
    getIt.registerLazySingleton<NavigationService>(() => navigationService);

  }

  static Future<void> initial() async {
    await initialDependency();
    await __authDependency();
    await __homeDependency();
  }
}
