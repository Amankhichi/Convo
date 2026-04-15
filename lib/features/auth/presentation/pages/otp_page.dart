import 'dart:async';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class ConvoOtpPage extends StatefulWidget {
  const ConvoOtpPage({super.key});

  @override
  State<ConvoOtpPage> createState() => _ConvoOtpPageState();
}

class _ConvoOtpPageState extends State<ConvoOtpPage> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int secondsRemaining = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    secondsRemaining = 30;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        t.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  void verifyOtp() {
    final otp = getOtp();

    if (otp.length == 6) {
      print("OTP Entered: $otp");

      // TODO: Call your API here

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP Verified")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter complete OTP")));
    }
  }

  Widget buildOtpBox(int index, double width) {
    return SizedBox(
      width: width,
      height: width,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.12;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),

            const Text(
              "Enter Verification Code",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "We have sent a 6 digit OTP to your number",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: size.height * 0.05),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => buildOtpBox(index, boxSize),
              ),
            ),

            SizedBox(height: size.height * 0.05),

            ElevatedButton(
              onPressed: () {
                final otp = getOtp();

                if (otp.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter complete OTP")),
                  );
                  return;
                }

                if (otp == "555555") {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("OTP Verified")));

                  // 👉 Navigate to Home Page
                  context.read<LoginBloc>().add(LoginEvent.checkNumber());
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Verify", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            secondsRemaining == 0
                ? TextButton(
                    onPressed: () {
                      startTimer();
                      print("Resend OTP");

                      // TODO: Call resend API
                    },
                    child: const Text("Resend OTP"),
                  )
                : Text(
                    "Resend OTP in 00:$secondsRemaining",
                    style: const TextStyle(color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}
