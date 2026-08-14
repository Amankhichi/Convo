import '../repository/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase({required this.repository});

  Future<bool> call(String phone) {
    return repository.sendOtp(phone);
  }
}
