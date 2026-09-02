import 'package:convo/app/localization/app_localizations.dart';
import 'package:convo/app/localization/language_manager.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/constants/app_constants.dart';
import 'package:convo/core/utils/validators.dart';
import 'package:convo/core/widgets/app_button.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/authentication/data/models/country_model.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_event.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_state.dart';
import 'package:convo/features/authentication/presentation/widgets/country_selector_sheet.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country.defaultCountry;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context, AppLocalizations? loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc?.translate("help_title") ?? "ConVo Help & Support"),
        content: Text(
          loc?.translate("help_body") ??
              "Need help logging in? Ensure your phone has active SMS service and internet connection. Contact support@convo.com.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text("English"),
              onTap: () {
                sl<LanguageManager>().switchLanguage('en');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text("हिन्दी (Hindi)"),
              onTap: () {
                sl<LanguageManager>().switchLanguage('hi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CountrySelectorSheet(
        selectedCountry: selectedCountry,
        onSelectCountry: (country) {
          setState(() {
            selectedCountry = country;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentSuccess) {
            Navigator.of(context).pushNamed(
              RouteNames.otp,
              arguments: {
                "countryCode": state.countryCode,
                "phoneNumber": state.phoneNumber,
              },
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message.contains("Network")
                      ? (loc?.translate("server_error_msg") ?? state.message)
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: AppColors.primary),
                  onPressed: () => _showHelpDialog(context, loc),
                ),
                IconButton(
                  icon: const Icon(Icons.language, color: AppColors.primary),
                  onPressed: () => _showLanguageSelector(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  /// ConVo Logo Badge Matching Splash Screen
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
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
                    loc?.translate("welcome_title") ?? "Welcome to ConVo",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.courgette(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    loc?.translate("connect_subtitle") ?? AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText(context),
                    ),
                  ),

                  const SizedBox(height: 36),

                  /// Input Section Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc?.translate("phone_number_label") ?? "Your Phone Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: AppColors.textColor(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Country Code Selector + 10-Digit Phone Input
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final containerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
                      final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Country Selector Button
                          InkWell(
                            onTap: () => _openCountryPicker(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: containerBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    selectedCountry.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedCountry.dialCode,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// Phone Input Field
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.textColor(context),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: loc?.translate("enter_phone_hint") ?? "10-digit phone number",
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  color: AppColors.greyText(context).withOpacity(0.7),
                                ),
                                filled: true,
                                fillColor: containerBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor, width: 1.8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  /// Prominent Continue Button
                  AppButton(
                    text: loc?.translate("continue_button") ?? "Continue",
                    isLoading: isLoading,
                    onPressed: () {
                      final rawText = phoneController.text.trim();
                      final error = Validators.validatePhone(rawText);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              rawText.isEmpty
                                  ? (loc?.translate("validation_empty_phone") ?? error)
                                  : (loc?.translate("validation_invalid_phone") ?? error),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FocusScope.of(context).unfocus();

                      context.read<AuthBloc>().add(
                            RequestOtpEvent(
                              countryCode: selectedCountry.dialCode,
                              phoneNumber: rawText,
                            ),
                          );
                    },
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
