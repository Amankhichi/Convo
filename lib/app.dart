import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/contact/presentation/bloc/contact_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => getIt<LoginBloc>()),
        BlocProvider<ChatBloc>(create: (context) => getIt<ChatBloc>()),
        BlocProvider<ContactBloc>(create: (context) => getIt<ContactBloc>()),
        BlocProvider<HomeBloc>(create: (context) => getIt<HomeBloc>()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'ConVO',
      ),
    );
  }
}
