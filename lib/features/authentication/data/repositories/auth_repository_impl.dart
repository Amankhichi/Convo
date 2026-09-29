import 'dart:typed_data';
import 'package:convo/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:convo/features/authentication/data/models/auth_request_model.dart';
import 'package:convo/features/authentication/data/models/auth_response_model.dart';
import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> requestOtp(String countryCode, String phoneNumber) async {
    final model = RequestOtpModel(countryCode: countryCode, phoneNumber: phoneNumber);
    return await _remoteDataSource.requestOtp(model);
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(
    String countryCode,
    String phoneNumber,
    String otp,
  ) async {
    final model = VerifyOtpModel(
      countryCode: countryCode,
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return await _remoteDataSource.verifyOtp(model);
  }

  @override
  Future<Map<String, dynamic>> createProfile(
    String name,
    String about,
    Uint8List? imageBytes,
  ) async {
    return await _remoteDataSource.createProfile(
      name: name,
      about: about,
      imageBytes: imageBytes,
    );
  }

  @override
  Future<bool> deleteAccount() async {
    return await _remoteDataSource.deleteAccount();
  }
}
