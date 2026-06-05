import 'package:flutter/material.dart';

class AppMediaQuery {
  /// Screen Width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Screen Height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Width Percentage
  static double w(BuildContext context, double value) {
    return MediaQuery.of(context).size.width * value;
  }

  /// Height Percentage
  static double h(BuildContext context, double value) {
    return MediaQuery.of(context).size.height * value;
  }

  /// Padding
  static EdgeInsets padding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(context, horizontal),
      vertical: h(context, vertical),
    );
  }

  /// Margin
  static EdgeInsets margin(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: w(context, horizontal),
      vertical: h(context, vertical),
    );
  }
}