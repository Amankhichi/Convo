import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:convo/features/home/presentation/pages/home_page.dart';
import 'package:convo/features/home/presentation/pages/singup_page.dart';
import 'package:flutter/material.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  @override
void initState() {
  super.initState();

  Future.delayed(const Duration(seconds: 2), () async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("id");
    print("test id $id");

if (id?.isNotEmpty == true) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => HomePage()),
  );
  context.read<SingupBloc>().add(SingupEvent.checkUser());
} else {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SingupPage()),
  );
}

  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔵 App Icon
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            // 🔤 App Name
            const Text(
              "ConVO",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // ✨ Tagline
            const Text(
              "Connect & Chat Instantly",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
