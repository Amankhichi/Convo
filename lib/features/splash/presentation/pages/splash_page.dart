import 'package:convo/app/router/route_names.dart';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/presence/presence_manager.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/splash/presentation/widgets/splash_content.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final localStorage = sl<LocalStorage>();
    final token = localStorage.getString(StorageKeys.jwtToken);

    if (token != null && token.isNotEmpty) {
      sl<PresenceManager>().start();
      Navigator.of(context).pushReplacementNamed(RouteNames.home);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashContent();
  }
}
