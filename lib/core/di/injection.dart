import 'package:flutter/material.dart';
import '../router/app_router.dart';

class Injection {
  static BuildContext get currentContext {
    final ctx = AppRouter.navigatorKey.currentContext;
    if (ctx == null) {
      throw FlutterError("Context not available");
    }
    return ctx;
  }
}
