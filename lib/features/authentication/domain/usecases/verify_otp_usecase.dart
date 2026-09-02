import 'package:convo/features/authentication/data/models/auth_response_model.dart';
import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<VerifyOtpResponseModel> execute(
    String countryCode,
    String phoneNumber,
    String otp,
  ) async {
    return await _repository.verifyOtp(countryCode, phoneNumber, otp);
  }
}
