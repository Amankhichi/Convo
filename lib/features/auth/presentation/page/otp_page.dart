import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/snackbar_widgets.dart';
import '../bloc/login_bloc.dart';

class ConvoOtpPage extends StatefulWidget {
  final String countryCode;
  final String mobileNumber;

  const ConvoOtpPage({
    super.key,
    required this.countryCode,
    required this.mobileNumber,
  });

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
          setState(() {});
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

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is VerifyOtpSuccess) {
          if (state.newUser) {
            context.go('/add-name?lotti=&mobileNumber=${Uri.encodeComponent(widget.mobileNumber)}');
          } else {
            context.go('/home');
          }
        } else if (state is VerifyOtpFailure) {
          showError(context, state.message);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final isVerifying = state is VerifyOtpLoading;

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
                  Text(
                    "We have sent a 6 digit OTP to ${widget.countryCode} ${widget.mobileNumber}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
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
                    onPressed: (getOtp().length == 6 && !isVerifying)
                        ? () {
                            context.read<LoginBloc>().add(
                                  LoginEvent.verifyOtp(
                                    otp: getOtp(),
                                    countryCode: widget.countryCode,
                                    mobileNumber: widget.mobileNumber,
                                  ),
                                );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Verify", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  secondsRemaining == 0
                      ? TextButton(
                          onPressed: () {
                            startTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Dummy OTP resent successfully.")),
                            );
                          },
                          child: const Text("Resend OTP"),
                        )
                      : Text(
                          "Resend OTP in 00:${secondsRemaining.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
