import '../../domain/entity/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../datasource/local/auth_local_datasource.dart';
import '../payload/user_payload.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<bool> sendOtp(String phone) async {
    return remoteDatasource.sendOtp(phone);
  }

  @override
  Future<VerifyOtpResult> verifyOtp({
    required String countryCode,
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await remoteDatasource.verifyOtp(
      countryCode: countryCode,
      mobileNumber: mobileNumber,
      otp: otp,
    );

    if (response.success) {
      if (response.token != null) {
        await localDatasource.cacheToken(response.token!);
      }
      if (response.user != null) {
        await localDatasource.cacheUserId(response.user!.id.toString());
        await localDatasource.cacheUserPhone(response.user!.phone);
        await localDatasource.cacheUser(response.user!);
      }
    }

    return VerifyOtpResult(
      success: response.success,
      newUser: response.newUser,
      token: response.token,
      user: response.user,
    );
  }

  @override
  Future<bool> completeProfile(UserPayload payload) async {
    final success = await remoteDatasource.addUser(payload);
    if (success) {
      final user = await remoteDatasource.isUser(payload.phone);
      if (user != null) {
        await localDatasource.cacheUserId(user.id.toString());
        await localDatasource.cacheUserPhone(user.phone);
      }
    }
    return success;
  }

  @override
  Future<UserEntity?> getUser(String phone) async {
    return remoteDatasource.isUser(phone);
  }

  @override
  Future<bool> updateUser(UserPayload payload) async {
    return remoteDatasource.updateUser(payload);
  }
}
