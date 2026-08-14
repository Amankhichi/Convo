import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 18,
    this.clr = AppColors.primary,
  });

  final IconData icon;
  final double size;
  final Color clr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(icon, color: clr, size: size),
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.size = 18,
    this.clr = AppColors.primary,
    this.bold = FontWeight.bold,
  });

  final String text;
  final double size;
  final Color clr;
  final FontWeight bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(color: clr, fontSize: size, fontWeight: bold),
      ),
    );
  }
}

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.controller,
    required this.onChanged,
  });

  final String label;
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
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
