import 'dart:typed_data';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/authentication/data/models/auth_request_model.dart';
import 'package:convo/features/authentication/data/models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> requestOtp(RequestOtpModel model);
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpModel model);
  Future<Map<String, dynamic>> createProfile({
    required String name,
    required String about,
    Uint8List? imageBytes,
  });
  Future<bool> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<bool> requestOtp(RequestOtpModel model) async {
    final res = await _apiClient.post(ApiConfig.requestOtp, body: model.toJson());
    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to send OTP");
      }
      return true;
    }
    return res != null;
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpModel model) async {
    final res = await _apiClient.post(ApiConfig.verifyOtp, body: model.toJson());
    if (res is Map<String, dynamic>) {
      return VerifyOtpResponseModel.fromJson(res);
    }
    throw Exception("Invalid OTP verify response");
  }

  @override
  Future<Map<String, dynamic>> createProfile({
    required String name,
    required String about,
    Uint8List? imageBytes,
  }) async {
    final res = await _apiClient.postMultipart(
      ApiConfig.profile,
      queryParameters: {
        "name": name,
        "about": about,
      },
      fileBytes: imageBytes,
    );
    if (res is Map<String, dynamic>) {
      return res;
    }
    throw Exception("Failed to save profile");
  }

  @override
  Future<bool> deleteAccount() async {
    final res = await _apiClient.delete(ApiConfig.deleteUser);
    return res != null;
  }
}
