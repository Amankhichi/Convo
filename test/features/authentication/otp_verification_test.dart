import 'package:convo/features/authentication/data/models/auth_request_model.dart';
import 'package:convo/features/authentication/data/models/auth_response_model.dart';
import 'package:convo/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OTP Validation Unit Tests', () {
    test('Empty OTP returns error', () {
      final res = Validators.validateOtp('');
      expect(res, 'Please enter OTP');
    });

    test('5-digit OTP returns error', () {
      final res = Validators.validateOtp('55555');
      expect(res, 'Please enter a valid 6-digit OTP');
    });

    test('6-digit valid OTP returns null error', () {
      final res = Validators.validateOtp('555555');
      expect(res, null);
    });
  });

  group('Verify OTP Models Test', () {
    test('VerifyOtpModel serializes correctly', () {
      const model = VerifyOtpModel(
        countryCode: '+91',
        phoneNumber: '8595626824',
        otp: '555555',
      );
      expect(model.toJson(), {
        'countryCode': '+91',
        'phoneNumber': '8595626824',
        'phone': '+918595626824',
        'otp': '555555',
      });
    });

    test('VerifyOtpResponseModel parses isNewUser true response correctly', () {
      final json = {
        'token': 'jwt_mock_token_123',
        'isNewUser': true,
      };
      final res = VerifyOtpResponseModel.fromJson(json);
      expect(res.token, 'jwt_mock_token_123');
      expect(res.isNewUser, true);
    });

    test('VerifyOtpResponseModel parses isNewUser false response correctly', () {
      final json = {
        'token': 'jwt_mock_token_456',
        'isNewUser': false,
        'user': {
          'id': 1,
          'phone': '+918595626824',
          'name': 'Test User',
          'about': 'Hey there',
          'profileImage': '',
        }
      };
      final res = VerifyOtpResponseModel.fromJson(json);
      expect(res.token, 'jwt_mock_token_456');
      expect(res.isNewUser, false);
      expect(res.user?.name, 'Test User');
    });
  });
}
