import 'dart:typed_data';
import 'package:convo/features/authentication/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<bool> requestOtp(String countryCode, String phoneNumber);
  Future<VerifyOtpResponseModel> verifyOtp(String countryCode, String phoneNumber, String otp);
  Future<Map<String, dynamic>> createProfile(String name, String about, Uint8List? imageBytes);
  Future<bool> deleteAccount();
}
