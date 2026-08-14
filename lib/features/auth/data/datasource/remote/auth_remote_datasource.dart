import 'package:convo/core/network/api_client.dart';
import 'package:convo/core/network/api_endpoints.dart';
import 'package:convo/core/network/api_exceptions.dart';
import '../../payload/user_payload.dart';
import 'package:convo/features/auth/data/model/user_model.dart';

import '../../model/verify_otp_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<bool> sendOtp(String phone);
  Future<VerifyOtpResponseModel> verifyOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  });
  Future<UserModel?> isUser(String phone);
  Future<bool> addUser(UserPayload payload);
  Future<bool> updateUser(UserPayload payload);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasourceImpl(this._apiClient);

  @override
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: {"phone": phone},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Send OTP Remote Error: $e");
      return false;
    }
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          "countryCode": countryCode,
          "mobileNumber": mobileNumber,
          "otp": otp,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return VerifyOtpResponseModel.fromJson(response.data as Map<String, dynamic>);
        }
      }
      throw const ApiException(message: "Failed to verify OTP from server");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> isUser(String phone) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allUsers);
      if (response.statusCode == 200) {
        final List data = response.data;
        final userData = data
            .where((e) => e['phone'].toString() == phone)
            .toList();
        if (userData.isEmpty) return null;
        return UserModel.fromJson(userData.first);
      }
      return null;
    } catch (e) {
      print("IsUser Remote Error: $e");
      return null;
    }
  }

  @override
  Future<bool> addUser(UserPayload payload) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addUser,
        data: payload.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("AddUser Remote Error: $e");
      return false;
    }
  }

  @override
  Future<bool> updateUser(UserPayload payload) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateUser,
        data: payload.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("UpdateUser Remote Error: $e");
      return false;
    }
  }
}
