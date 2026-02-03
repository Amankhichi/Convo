import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:convo/features/home/presentation/widgets/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = countries.first;
  @override
void initState() {
  super.initState();
  phoneController.text;
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                "ConVO",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

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
                        items: countries
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Row(
                                  children: [
                                    Text(c.flag),
                                    const SizedBox(width: 6),
                                    Text(c.code),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (c) => setState(() => selectedCountry = c!),
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
                        // LengthLimitingTextInputFormatter(
                        //   10,
                        // ),
                      ],
                      onChanged: (value) {
                        context.read<SingupBloc>().add(
                          SingupEvent.phone(value),
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
      backgroundColor: phoneController.text.isNotEmpty
          ? AppColors.primary
          : Colors.grey.shade400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    onPressed: phoneController.text.length == 10
        ? () {
            context.read<SingupBloc>().add(
              SingupEvent.checkUser(),
            );
          }
        : null,
    child: Text(
      "Continue",
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

              Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColor(context),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
