class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your phone number";
    }
    final cleanPhone = value.trim();
    if (cleanPhone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return "Please enter a valid 10-digit phone number";
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter OTP";
    }
    final cleanOtp = value.trim();
    if (cleanOtp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(cleanOtp)) {
      return "Please enter a valid 6-digit OTP";
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your name";
    }
    return null;
  }
}
