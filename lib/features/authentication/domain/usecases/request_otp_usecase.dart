import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';

class RequestOtpUseCase {
  final AuthRepository _repository;

  RequestOtpUseCase(this._repository);

  Future<bool> execute(String countryCode, String phoneNumber) async {
    return await _repository.requestOtp(countryCode, phoneNumber);
  }
}
