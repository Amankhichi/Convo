import 'dart:ui';
import 'package:convo/core/const.dart/constant.dart';
import 'package:flutter/material.dart';

class AppColors {
  static Color textColor(BuildContext context) => Constant.isDark(context)?Colors.white:Color(0xFF0088CC);
  static Color AppBarColor(BuildContext context) => Constant.isDark(context)?Colors.black :Color(0xFF0088CC);

  static Color invertTextColor(BuildContext context) => !Constant.isDark(context) ? Colors.white : Colors.black;
  static Color backgroundColor(BuildContext context) => Constant.isDark(context) ? const Color.fromARGB(255, 31, 29, 29) : Colors.white;
  static Color iconColor(BuildContext context) => !Constant.isDark(context) ? Colors.black : Colors.white;
  static Color matchTheme(BuildContext context) => Constant.isDark(context) ? Colors.black : Colors.white;
  static Color opositeTheme(BuildContext context) => !Constant.isDark(context) ? Colors.black : Colors.white;
  static Color green = Colors.green;
  static Color primary = const Color(0xFF0088CC);
  static Color background(BuildContext context) => Constant.isDark(context)?Color(0xFF0088CC):Colors.white;

}
