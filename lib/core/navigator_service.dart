import 'package:flutter/material.dart';

class NavigationService {
  factory NavigationService() => _singleton;
  NavigationService._init();
  static final NavigationService _singleton = NavigationService._init();

  final GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> ScaffoldMessengerkey =
      GlobalKey<ScaffoldMessengerState>();

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorkey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> push<T>(Route<T> route) {
    return navigatorkey.currentState!.push<T>(route);
  }

  Future<T?> pushNamedAndRemoveAll<T>(String routeName, {Object? arguments}) {
    return navigatorkey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop<T>([T? result]) {
    return navigatorkey.currentState!.pop<T>(result);
  }
}

