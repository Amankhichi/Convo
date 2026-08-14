import 'package:convo/core/network/api_client.dart';
import 'package:convo/core/network/api_endpoints.dart';
import 'package:convo/core/network/api_exceptions.dart';
import '../../model/request_otp_response.dart';

abstract class LoginRemoteDataSource {
  Future<RequestOtpResponse> requestOtp(
    String countryCode,
    String mobileNumber,
  );
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiClient _apiClient;

  LoginRemoteDataSourceImpl(this._apiClient);

  @override
  Future<RequestOtpResponse> requestOtp(
    String countryCode,
    String mobileNumber,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestOtp,
        data: {"countryCode": countryCode, "mobileNumber": mobileNumber},
      );
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is Map<String, dynamic>) {
          return RequestOtpResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
        } else {
          return RequestOtpResponse(message: "OTP requested successfully");
        }
      }

      throw const ApiException(message: "Failed to request OTP from server");
    } catch (e) {
      rethrow;
    }
  }
}
