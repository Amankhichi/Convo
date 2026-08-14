import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../di/injection.dart';

class Constant {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class AppColors {
  static Color textColor(BuildContext context) =>
      Constant.isDark(context) ? Colors.white : const Color(0xFF1F1D1D);
  
  static Color invertTextColor(BuildContext context) =>
      Constant.isDark(context) ? Colors.black : Colors.white;
  
  static Color incomingMessageBg(BuildContext context) =>
      Constant.isDark(context)
      ? const Color(0xFF2A2A2A)
      : const Color(0xFFEFEFEF);
  
  static Color sendBT(BuildContext context) =>
      Constant.isDark(context) ? const Color(0xFF0088CC) : Colors.white;
  
  static Color appBarColor(BuildContext context) => Constant.isDark(context)
      ? const Color(0xFF1C1C1C)
      : const Color(0xFF0088CC);
  
  static Color chatProfileColor(BuildContext context) =>
      Constant.isDark(context)
      ? const Color(0xFF121212)
      : const Color(0xFF0088CC);
  
  static Color backgroundColor(BuildContext context) => Constant.isDark(context)
      ? const Color(0xFF1F1D1D)
      : const Color(0xFFF5F5F5);
  
  static Color inputBackground(BuildContext context) =>
      Constant.isDark(context) ? const Color(0xFF2A2A2A) : Colors.white;
  
  static Color get iconColor =>
      Constant.isDark(Injection.currentContext) ? Colors.white : Colors.black;
  
  static Color secondaryColor(BuildContext context) => Constant.isDark(context)
      ? const Color(0xFF3A3A3A)
      : const Color(0xFFD6D6D6);
  
  static Color greyText(BuildContext context) => Constant.isDark(context)
      ? const Color(0xFFAAAAAA)
      : const Color(0xFF666666);

  static const Color primary = Color(0xFF0088CC);
  static const Color green = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;

  static const Color blueGray = Color(0xFF1E293B);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color scaffoldBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color surface = Color(0xFF0F172A);
  static const Color authBg1 = Color(0xFF0B1528);
}

extension ThemeContextExtensions on BuildContext {
  Color get appText => AppColors.textColor(this);
  Color get appMutedText => AppColors.greyText(this);
  Color get appSurface => Constant.isDark(this) ? const Color(0xFF2A2A2A) : Colors.white;
  Color get appBorder => Constant.isDark(this) ? Colors.white10 : const Color(0xFFE2E8F0);
}

class AppAppBarTheme {
  static AppBarTheme get light => const AppBarTheme(backgroundColor: AppColors.primary);
  static AppBarTheme get dark => const AppBarTheme(backgroundColor: Colors.black);
}

class AppTextTheme {
  static TextTheme get lightTextTheme => const TextTheme();
  static TextTheme get darkTextTheme => const TextTheme();
}

class AppTheme {
  static TextTheme _font(TextTheme base) => GoogleFonts.interTextTheme(base);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    appBarTheme: AppAppBarTheme.light,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F8FC),
    textTheme: _font(AppTextTheme.lightTextTheme),
    fontFamily: GoogleFonts.inter().fontFamily,
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF334155)),
    dividerColor: const Color(0xFFE2E8F0),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF475569),
      textColor: Color(0xFF0F172A),
      tileColor: Colors.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: _font(AppTextTheme.lightTextTheme).titleLarge?.copyWith(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: _font(
        AppTextTheme.lightTextTheme,
      ).bodyMedium?.copyWith(color: const Color(0xFF475569)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : const Color(0xFFCBD5E1),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary.withOpacity(.28)
            : const Color(0xFFE2E8F0),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.blueGray,
      selectedItemColor: AppColors.cyan,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    appBarTheme: AppAppBarTheme.dark,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    textTheme: _font(AppTextTheme.darkTextTheme),
    fontFamily: GoogleFonts.inter().fontFamily,
    cardColor: AppColors.darkCard,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    dividerColor: Colors.white10,
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white70,
      textColor: Colors.white,
      tileColor: AppColors.darkSurface,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: _font(
        AppTextTheme.darkTextTheme,
      ).titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
      contentTextStyle: _font(
        AppTextTheme.darkTextTheme,
      ).bodyMedium?.copyWith(color: Colors.white70),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.white70,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary.withOpacity(.32)
            : Colors.white24,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.blueGray,
      selectedItemColor: AppColors.cyan,
      unselectedItemColor: Colors.white60,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyan,
        side: const BorderSide(color: AppColors.cyan),
      ),
    ),
  );

  static ThemeData authTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.authBg1,
    primaryColor: AppColors.cyan,
    useMaterial3: false,
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.cyan, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}
