import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  final IconData? prefixIcon;
  final Color? iconColor;

  /// NEW
  final double? iconSize;

  final Color? textColor;
  final Color? hintColor;

  final Color? fillColor;
  final bool filled;

  final double borderRadius;

  final bool autofocus;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.iconColor,
    this.iconSize, // NEW
    this.textColor,
    this.hintColor,
    this.fillColor,
    this.filled = true,
    this.borderRadius = 14,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      autofocus: autofocus,
      readOnly: readOnly,

      autocorrect: false,
      enableSuggestions: false,
      spellCheckConfiguration:
          SpellCheckConfiguration.disabled(),

      cursorColor: textColor ?? Colors.white,

      style: TextStyle(
        color: textColor ?? Colors.white,
      ),

      onChanged: onChanged,
      onTap: onTap,

      decoration: InputDecoration(
        hintText: hintText ?? "Search",

        hintStyle: TextStyle(
          color: hintColor ?? Colors.grey,
        ),

        filled: filled,
        fillColor: fillColor ?? Colors.transparent,

        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: iconColor ?? Colors.grey,
                size: iconSize ?? 24, // NEW
              )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),

        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}