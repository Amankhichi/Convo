import 'package:convo/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:convo/const.dart/constant.dart';
import 'package:flutter/services.dart';
// Note: Assuming GoogleFonts comes from your packages, ensure 'google_fonts' is in pubspec.yaml
import 'package:google_fonts/google_fonts.dart'; 

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

  // Constants
  static const Color primary = Color(0xFF0088CC);
  static const Color green = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;

  // Added Missing Theme Colors to prevent AppTheme compilation errors
  static const Color blueGray = Color(0xFF1E293B);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color scaffoldBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color surface = Color(0xFF0F172A);
  static const Color authBg1 = Color(0xFF0B1528);
}

// Added Context Extensions to map missing surface/text features automatically
extension ThemeContextExtensions on BuildContext {
  Color get appText => AppColors.textColor(this);
  Color get appMutedText => AppColors.greyText(this);
  Color get appSurface => Constant.isDark(this) ? const Color(0xFF2A2A2A) : Colors.white;
  Color get appBorder => Constant.isDark(this) ? Colors.white10 : const Color(0xFFE2E8F0);
}

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 68 : 82);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final showBackButton = showBack && (onBack != null || canPop);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              showBackButton ? 4 : 20,
              4,
              16,
              10,
            ),
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .78),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const PremiumSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: context.appBorder),
              ),
              child: Icon(icon, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appMutedText, height: 1.45),
            ),
            if (action != null) ...[const SizedBox(height: 22), action!],
          ],
        ),
      ),
    );
  }
}

// Mock placeholders to ensure AppTheme compiles cleanly
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

  /// 🌞 Light Theme
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
            ? AppColors.primary.withValues(alpha: .28)
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

  /// 🌙 Dark Theme
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
            ? AppColors.primary.withValues(alpha: .32)
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