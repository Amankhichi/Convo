import 'package:convo/app/config/app_config.dart';
import 'package:convo/app/localization/app_localizations.dart';
import 'package:convo/app/localization/language_manager.dart';
import 'package:convo/app/router/app_router.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_theme.dart';
import 'package:convo/features/calling/presentation/bloc/call_bloc.dart';
import 'package:convo/features/calling/presentation/widgets/call_lifecycle_observer.dart';
import 'package:convo/features/calling/presentation/widgets/incoming_call_listener.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ConvoApp extends StatelessWidget {
  final AppConfig config;

  const ConvoApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CallBloc>(
      create: (_) => sl<CallBloc>(),
      child: ValueListenableBuilder<Locale>(
        valueListenable: sl<LanguageManager>(),
        builder: (context, currentLocale, child) {
          return MaterialApp(
            navigatorKey: AppRouter.navigatorKey,
            title: config.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: currentLocale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) {
              return CallLifecycleObserver(
                child: IncomingCallListener(
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
