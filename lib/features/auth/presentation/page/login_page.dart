import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widget/country.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = countries.first;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Select Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text("English"),
                leading: const Icon(Icons.language),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Language changed to English"),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("Hindi (हिंदी)"),
                leading: const Icon(Icons.language),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Language changed to Hindi")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is RequestOtpSuccess) {
          context.push(
            '/otp?countryCode=${Uri.encodeComponent(selectedCountry.code)}&mobileNumber=${Uri.encodeComponent(phoneController.text)}',
          );
        } else if (state is RequestOtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final isLoading = state is RequestOtpLoading;

          return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ConVo",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.language),
                        onPressed: () => _showLanguagePicker(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Enter your phone number",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We will send you a verification code",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Country>(
                            value: selectedCountry,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: countries.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Row(
                                  children: [
                                    Text(c.flag),
                                    const SizedBox(width: 6),
                                    Text(c.code),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (c) {
                              setState(() => selectedCountry = c!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (value) {
                            setState(() {});
                            context.read<LoginBloc>().add(
                              LoginEvent.phone(value),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: "Phone number",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: phoneController.text.length == 10
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: (phoneController.text.length == 10 && !isLoading)
                          ? () {
                              context.read<LoginBloc>().add(
                                    RequestOtpEvent(
                                      countryCode: selectedCountry.code,
                                      mobileNumber: phoneController.text,
                                    ),
                                  );
                            }
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Send OTP",
                              style: TextStyle(
                                fontSize: 18,
                                color: phoneController.text.length == 10
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      "By continuing, you agree to our Terms & Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
