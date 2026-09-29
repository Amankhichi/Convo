import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/app/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;
  final Color? textColor;
  final Color? hintColor;
  final Color? fillColor;
  final Color? iconColor;
  final double? iconSize;
  final double borderRadius;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText = "",
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.textColor,
    this.hintColor,
    this.fillColor,
    this.iconColor,
    this.iconSize,
    this.borderRadius = AppDimensions.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    Widget? effectivePrefix = prefixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onTap: onTap,
          autofocus: autofocus,
          readOnly: readOnly,
          style: TextStyle(color: textColor ?? AppColors.textColor(context)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintColor != null ? TextStyle(color: hintColor) : null,
            errorText: errorText,
            prefixIcon: effectivePrefix,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
