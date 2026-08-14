import '../repository/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<VerifyOtpResult> call({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  }) {
    return repository.verifyOtp(
      countryCode: countryCode,
      mobileNumber: mobileNumber,
      otp: otp,
    );
  }
}
