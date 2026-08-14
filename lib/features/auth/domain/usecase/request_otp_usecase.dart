import 'package:convo/core/utils/result.dart';
import '../repository/login_repository.dart';
import '../../data/model/request_otp_response.dart';

class RequestOtpUseCase {
  final LoginRepository repository;

  RequestOtpUseCase({required this.repository});

  Future<Result<RequestOtpResponse>> call({
    required String countryCode,
    required String mobileNumber,
  }) {
    return repository.requestOtp(
      countryCode: countryCode,
      mobileNumber: mobileNumber,
    );
  }
}
