import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/model/user_model.dart';
import '../../features/home/presentation/page/splash_page.dart';
import '../../features/auth/presentation/page/welcome_page.dart';
import '../../features/auth/presentation/page/login_page.dart';
import '../../features/auth/presentation/page/otp_page.dart';
import '../../features/auth/presentation/page/add_name_page.dart';
import '../../features/home/presentation/page/home_page.dart';
import '../../features/chat/presentation/page/chat_page.dart';
import '../../features/contact/presentation/page/contact_page.dart';
import '../../features/contact/presentation/page/create_group_page.dart';
import '../../features/auth/presentation/page/profile_page.dart';
import '../../features/auth/presentation/page/edit_profile_page.dart';
import '../../features/chat/presentation/page/voice_call_page.dart';
import '../../features/chat/presentation/page/video_call_page.dart';
import '../../features/chat/presentation/page/contact_user_profile_page.dart';
import '../../features/home/presentation/page/add_stroy_page.dart';
import '../../features/home/presentation/page/unread_mssg_chat_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final countryCode = state.uri.queryParameters['countryCode'] ?? '';
          final mobileNumber = state.uri.queryParameters['mobileNumber'] ?? '';
          return ConvoOtpPage(countryCode: countryCode, mobileNumber: mobileNumber);
        },
      ),
      GoRoute(
        path: '/add-name',
        builder: (context, state) {
          final lotti = state.uri.queryParameters['lotti'] ?? '';
          final mobileNumber = state.uri.queryParameters['mobileNumber'];
          return AddNamePage(lotti: lotti, mobileNumber: mobileNumber);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return ChatPage(user: user);
        },
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactsPage(),
      ),
      // GoRoute(
      //   path: '/dialpad',
      //   builder: (context, state) => const DailpadPage(),
      // ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const CreateGroupPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/voice-call',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return VoiceCallPage(user: user);
        },
      ),
      GoRoute(
        path: '/video-call',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return VideoCallPage(user: user);
        },
      ),
      GoRoute(
        path: '/contact-profile',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return ContactUserProfilePage(user: user);
        },
      ),
      GoRoute(
        path: '/add-story',
        builder: (context, state) => const AddStoryPage(),
      ),
      // GoRoute(
      //   path: '/view-story',
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;

      //     return ViewStoryPage(
      //       stories: extra['stories'] as List<StoryModel>,
      //       initialIndex: extra['initialIndex'] as int,
      //     );
      //   },
      // ),
      GoRoute(
        path: '/unread-chat',
        builder: (context, state) {
          return const UnreadMssgChatPage();
        },
      ),
    ],
  );
}
