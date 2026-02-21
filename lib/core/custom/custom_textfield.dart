import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.controller,
    required this.onChanged,
  });

  final String label; // 👈 ADD THIS
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label, // 👈 now works
          floatingLabelBehavior: FloatingLabelBehavior.auto,

          filled: true,
          fillColor: Colors.grey.shade100,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.8,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
      ),
    );
  }
}
