import 'dart:async';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:convo/features/home/presentation/pages/home_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key,});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(
        context
      ).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage()), (route)=>false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingupBloc, SingupState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Lottie.asset('assets/lottie/party_left.json', width: 120),
              // ),

              // /// Right party popper
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Lottie.asset('assets/lottie/party_right.json', width: 120),
              // ),

              /// Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: "Welcome ${state.name} 🎉",
                      size: 26,
                      bold: FontWeight.w700,
                    ),
                    CustomText(text: "ConVO", size: 22, bold: FontWeight.w700),
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
