import 'package:convo/features/authentication/domain/repositories/auth_repository.dart';
import 'package:convo/features/authentication/domain/usecases/delete_account_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository implements AuthRepository {
  bool deleteCalled = false;
  bool shouldSucceed = true;

  @override
  Future<bool> deleteAccount() async {
    deleteCalled = true;
    return shouldSucceed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Logout & Delete Account Unit Tests', () {
    test('DeleteAccountUseCase executes repository deleteAccount call', () async {
      final mockRepo = MockAuthRepository();
      final useCase = DeleteAccountUseCase(mockRepo);

      final result = await useCase.execute();

      expect(mockRepo.deleteCalled, isTrue);
      expect(result, isTrue);
    });

    test('DeleteAccountUseCase returns false when repository fails', () async {
      final mockRepo = MockAuthRepository()..shouldSucceed = false;
      final useCase = DeleteAccountUseCase(mockRepo);

      final result = await useCase.execute();

      expect(mockRepo.deleteCalled, isTrue);
      expect(result, isFalse);
    });
  });
}
