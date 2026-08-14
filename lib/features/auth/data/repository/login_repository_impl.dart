import 'package:convo/core/network/api_exceptions.dart';
import 'package:convo/core/utils/result.dart';
import '../../domain/repository/login_repository.dart';
import '../datasource/remote/login_remote_datasource.dart';
import '../model/request_otp_response.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<RequestOtpResponse>> requestOtp({
    required String countryCode,
    required String mobileNumber,
  }) async {
    try {
      final response = await remoteDataSource.requestOtp(countryCode, mobileNumber);
      return Success(response);
    } on NetworkException catch (e) {
      return FailureResult(e.message);
    } on ServerException catch (e) {
      return FailureResult(e.message);
    } on ValidationException catch (e) {
      return FailureResult(e.message);
    } on ApiException catch (e) {
      return FailureResult(e.message);
    } catch (e) {
      return FailureResult(e.toString());
    }
  }
}
