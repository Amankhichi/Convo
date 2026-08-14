import 'package:convo/core/utils/result.dart';
import '../../data/model/request_otp_response.dart';

abstract class LoginRepository {
  Future<Result<RequestOtpResponse>> requestOtp({
    required String countryCode,
    required String mobileNumber,
  });
}
