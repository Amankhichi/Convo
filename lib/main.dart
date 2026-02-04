import 'package:convo/core/di/injection.dart';
import 'package:convo/features/home/presentation/pages/splash_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main()async {
  await Injection.initial();
runApp( DevicePreview(
      // enabled: !kReleaseMode, 
      enabled: false, 
      builder: (context) => const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InjectionBloc.singupbloc),
        BlocProvider(create: (context) => InjectionBloc.chatbloc),
      ],
child: MaterialApp(
          navigatorKey: Injection.navigatorState,
          debugShowCheckedModeBanner: false,
          home: const SplashPage(),
        ),
    );
  }
}