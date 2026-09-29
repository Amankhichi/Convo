import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle logoStyle({Color color = Colors.white}) {
    return GoogleFonts.courgette(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle heading1({required Color color}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle heading2({required Color color}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle body1({required Color color}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle caption({required Color color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }
}
