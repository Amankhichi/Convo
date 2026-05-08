import 'package:flutter/material.dart';

bool isDeviceThemeDark(BuildContext context) {
  Brightness brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.dark;
}

class Constant {
  static bool isDark(BuildContext context) => isDeviceThemeDark(context);
}
