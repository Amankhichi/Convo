class RequestOtpModel {
  final String countryCode;
  final String phoneNumber;

  const RequestOtpModel({
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
    };
  }
}

class VerifyOtpModel {
  final String countryCode;
  final String phoneNumber;
  final String otp;

  const VerifyOtpModel({
    required this.countryCode,
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "countryCode": countryCode,
      "phoneNumber": phoneNumber,
      "phone": "$countryCode$phoneNumber",
      "otp": otp,
    };
  }
}
