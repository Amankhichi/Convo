import 'package:convo/app/router/route_names.dart';
import 'package:convo/features/authentication/presentation/pages/login_page.dart';
import 'package:convo/features/authentication/presentation/pages/otp_page.dart';
import 'package:convo/features/calling/presentation/pages/call_page.dart';
import 'package:convo/features/chats/presentation/pages/chat_page.dart';
import 'package:convo/features/contacts/presentation/pages/contacts_page.dart';
import 'package:convo/features/contacts/presentation/pages/contact_profile_page.dart';
import 'package:convo/features/home/presentation/pages/home_page.dart';
import 'package:convo/features/media/presentation/pages/media_picker_page.dart';
import 'package:convo/features/profile/presentation/pages/profile_page.dart';
import 'package:convo/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:convo/features/settings/presentation/pages/settings_page.dart';
import 'package:convo/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case RouteNames.otp:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OtpPage(
            countryCode: args["countryCode"]?.toString() ?? "+91",
            phoneNumber: args["phoneNumber"]?.toString() ?? "",
          ),
        );

      case RouteNames.profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupPage());

      case RouteNames.contactProfile:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ContactProfilePage(
            name: args["name"]?.toString() ?? "ConVo Contact",
            phone: args["phone"]?.toString() ?? "",
            image: args["image"]?.toString() ?? "",
            about: args["about"]?.toString() ?? "",
            isOnline: args["online"] == true,
          ),
        );

      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteNames.chat:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ChatPage(
            chatId: args["chatId"] is int
                ? args["chatId"]
                : int.tryParse(args["chatId"]?.toString() ?? '0') ?? 0,
            targetUserId: args["targetUserId"] is int
                ? args["targetUserId"]
                : int.tryParse(args["targetUserId"]?.toString() ?? '0') ?? 0,
            contactName: args["contactName"]?.toString() ?? "ConVo Contact",
            contactPhone: args["contactPhone"]?.toString() ?? "",
            contactImage: args["contactImage"]?.toString() ?? "",
            contactAbout: args["contactAbout"]?.toString() ?? "",
            isOnline: args["online"] == true,
          ),
        );

      case RouteNames.contacts:
        return MaterialPageRoute(builder: (_) => const ContactsPage());

      case RouteNames.media:
        return MaterialPageRoute(builder: (_) => const MediaPickerPage());

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case RouteNames.calling:
        return MaterialPageRoute(builder: (_) => const CallPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("No route defined for ${settings.name}")),
          ),
        );
    }
  }
}
