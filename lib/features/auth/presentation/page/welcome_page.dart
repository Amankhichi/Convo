import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/login_bloc.dart';
import '../../../../core/widgets/custom_widgets.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: "Welcome ${state.nickName} 🎉",
                      size: 26,
                      bold: FontWeight.w700,
                    ),
                    const CustomText(text: "ConVO", size: 22, bold: FontWeight.w700),
                    const SizedBox(height: 12),
                    const Text(
                      """We’re excited to have you here. Convo is designed to bring people closer by making 
                      conversations more meaningful, engaging, and enjoyable. Whether you’re connecting with 
                      friends, meeting new people, or simply sharing your thoughts, Convo gives you a smooth 
                      and friendly space to express yourself freely. With personalized avatars, interactive 
                      features, and a simple yet powerful interface, every conversation feels more personal and 
                      alive.
                     At Convo, we believe communication should be effortless and fun. Explore new ways to chat, customize 
                     your profile, and enjoy a secure environment where your voice truly matters. This is your space to connect, 
                     share moments, and create memories—one conversation at a time. Let’s get started and make every chat count. Welcome 
                     to the Convo community!""",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
