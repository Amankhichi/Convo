import 'package:convo/app/app.dart';
import 'package:convo/app/config/app_config.dart';
import 'package:convo/app/config/environment.dart';
import 'package:convo/core/constants/app_constants.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection & core storage
  await initDependencyInjection();

  const config = AppConfig(
    appTitle: AppConstants.appName,
    environment: Environment.dev,
  );

  runApp(const ConvoApp(config: config));
}
