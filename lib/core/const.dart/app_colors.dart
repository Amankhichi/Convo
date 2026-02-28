// import 'dart:ui';
// import 'package:convo/core/const.dart/constant.dart';
// import 'package:flutter/material.dart';

// class AppColors {
//   static Color textColor(BuildContext context) => Constant.isDark(context)?Colors.white:Color(0xFF0088CC);
//   static Color ChatprofileColor(BuildContext context) => Constant.isDark(context)?Colors.black :Color(0xFF0088CC);
//   static Color AppBarColor(BuildContext context) => Constant.isDark(context)?Colors.white.withOpacity(0.08) :Color(0xFF0088CC);
//   static Color invertTextColor(BuildContext context) => Constant.isDark(context) ? Colors.white : Colors.black;
//   static Color backgroundColor(BuildContext context) => Constant.isDark(context) ? const Color.fromARGB(255, 31, 29, 29) : const Color.fromARGB(255, 238, 235, 235);
//   static Color iconColor(BuildContext context) => !Constant.isDark(context) ? Colors.black : Colors.white;
//   static Color matchTheme(BuildContext context) => Constant.isDark(context) ?  Colors.black : Colors.white;
//   static Color opositeTheme(BuildContext context) => !Constant.isDark(context) ? Colors.black : Colors.white;
//   static Color green = Colors.green;
//   static Color primary = const Color(0xFF0088CC);
//   static Color background(BuildContext context) => Constant.isDark(context)?Color(0xFF0088CC):Colors.white;

//   static Color greyTowhite(BuildContext context) => Constant.isDark(context) ? const Color.fromARGB(255, 238, 235, 235): const Color.fromARGB(255, 31, 29, 29) ;


// }


import 'package:flutter/material.dart';
import 'package:convo/core/const.dart/constant.dart';

class AppColors {

  static Color textColor(BuildContext context) =>Constant.isDark(context) ? Colors.white : const Color(0xFF1F1D1D);
  static Color invertTextColor(BuildContext context) =>Constant.isDark(context) ? Colors.black : Colors.white;
  static Color incomingMessageBg(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF);
  static Color sendBT(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF0088CC) : Colors.white;
  static Color appBarColor(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF1C1C1C) : const Color(0xFF0088CC);
  static Color chatProfileColor(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF121212) : const Color(0xFF0088CC);
  static Color backgroundColor(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF1F1D1D) : const Color(0xFFF5F5F5);
  static Color inputBackground(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF2A2A2A) : Colors.white;
  static Color iconColor(BuildContext context) =>Constant.isDark(context) ? Colors.white : Colors.black;
  static Color secondaryColor(BuildContext context) =>Constant.isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFD6D6D6);


  static const Color primary = Color(0xFF0088CC);
  static const Color green = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static Color greyText(BuildContext context) =>Constant.isDark(context) ? const Color(0xFFAAAAAA) : const Color(0xFF666666);
}