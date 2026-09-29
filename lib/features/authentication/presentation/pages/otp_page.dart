import 'dart:async';
import 'package:convo/app/localization/app_localizations.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/utils/validators.dart';
import 'package:convo/core/widgets/app_button.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_event.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;

  const OtpPage({
    super.key,
    this.countryCode = "+91",
    this.phoneNumber = "",
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int secondsRemaining = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNodes[0].requestFocus();
      }
    });
  }

  void _startTimer() {
    timer?.cancel();
    setState(() {
      secondsRemaining = 30;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining == 0) {
        t.cancel();
      } else {
        setState(() => secondsRemaining--);
      }
    });
  }

  String _getOtp() {
    return controllers.map((c) => c.text.trim()).join();
  }

  void _clearOtp() {
    for (var c in controllers) {
      c.clear();
    }
    focusNodes[0].requestFocus();
  }

  void _handlePaste(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    if (cleanValue.length == 6) {
      for (int i = 0; i < 6; i++) {
        controllers[i].text = cleanValue[i];
      }
      focusNodes[5].requestFocus();
    }
  }

  void _triggerVerify(BuildContext context) {
    final otp = _getOtp();
    final error = Validators.validateOtp(otp);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate("validation_invalid_otp") ??
                "Please enter the 6-digit OTP",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
          VerifyOtpEvent(
            countryCode: widget.countryCode,
            phoneNumber: widget.phoneNumber,
            otp: otp,
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
    final loc = AppLocalizations.of(context);
    final displayPhone = widget.phoneNumber.isNotEmpty
        ? "${widget.countryCode} ${widget.phoneNumber}"
        : "your number";

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerifiedSuccess) {
            if (state.response.isNewUser) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.profileSetup,
                (route) => false,
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.home,
                (route) => false,
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message.contains("Invalid OTP") || state.message.contains("Exception")
                      ? "Invalid OTP. Please check the code and try again."
                      : state.message,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return AppScaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  /// ConVo Logo Badge Matching Splash & Login UI
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/convi_icon.png",
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          "assests/img/convo_icon.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc?.translate("verify_phone_header") ?? "Verify your phone number",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.courgette(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    loc?.translate("enter_otp_subtitle") ??
                        "Enter the 6-digit OTP sent to your phone number",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText(context),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Dynamic Phone Number Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayPhone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  /// 6-Digit OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 48 - 50) / 6,
                        height: 54,
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.length > 1) {
                              _handlePaste(val);
                              return;
                            }
                            if (val.isNotEmpty) {
                              if (index < 5) {
                                focusNodes[index + 1].requestFocus();
                              } else {
                                // Auto-trigger verification on 6th digit
                                if (_getOtp().length == 6 && !isLoading) {
                                  _triggerVerify(context);
                                }
                              }
                            } else {
                              if (index > 0) {
                                focusNodes[index - 1].requestFocus();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Verify OTP Button
                  AppButton(
                    text: isLoading
                        ? (loc?.translate("verifying") ?? "Verifying...")
                        : (loc?.translate("verify_otp") ?? "Verify OTP"),
                    isLoading: isLoading,
                    onPressed: () => _triggerVerify(context),
                  ),

                  const SizedBox(height: 24),

                  /// Resend OTP Section with 30s Countdown Timer
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        loc?.translate("didnt_receive_otp") ?? "Didn't receive the code? ",
                        style: TextStyle(color: AppColors.greyText(context), fontSize: 14),
                      ),
                      secondsRemaining == 0
                          ? TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _startTimer();
                                      _clearOtp();
                                      context.read<AuthBloc>().add(
                                            RequestOtpEvent(
                                              countryCode: widget.countryCode,
                                              phoneNumber: widget.phoneNumber,
                                            ),
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("OTP Resent successfully."),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                              child: Text(
                                loc?.translate("resend_otp") ?? "Resend OTP",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Text(
                              "Resend in 00:${secondsRemaining.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                    ],
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
