import '../entity/user_entity.dart';
import '../../data/payload/user_payload.dart';

class VerifyOtpResult {
  final bool success;
  final bool newUser;
  final String? token;
  final UserEntity? user;

  VerifyOtpResult({
    required this.success,
    required this.newUser,
    this.token,
    this.user,
  });
}

abstract class AuthRepository {
  Future<bool> sendOtp(String phone);
  Future<VerifyOtpResult> verifyOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  });
  Future<bool> completeProfile(UserPayload payload);
  Future<UserEntity?> getUser(String phone);
  Future<bool> updateUser(UserPayload payload);
}
