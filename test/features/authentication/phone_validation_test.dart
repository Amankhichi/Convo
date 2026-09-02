import 'package:convo/core/utils/validators.dart';
import 'package:convo/features/authentication/data/models/auth_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phone Number Validation Tests', () {
    test('Empty phone returns validation error', () {
      final res = Validators.validatePhone('');
      expect(res, 'Please enter your phone number');
    });

    test('9-digit phone returns invalid length error', () {
      final res = Validators.validatePhone('859562682');
      expect(res, 'Please enter a valid 10-digit phone number');
    });

    test('11-digit phone returns invalid length error', () {
      final res = Validators.validatePhone('85956268245');
      expect(res, 'Please enter a valid 10-digit phone number');
    });

    test('Alphabetic characters return invalid character error', () {
      final res = Validators.validatePhone('85956abc24');
      expect(res, 'Please enter a valid 10-digit phone number');
    });

    test('Valid 10-digit phone returns null error', () {
      final res = Validators.validatePhone('8595626824');
      expect(res, null);
    });
  });

  group('Request OTP Model Serialization Test', () {
    test('RequestOtpModel serializes countryCode and phoneNumber correctly', () {
      const model = RequestOtpModel(countryCode: '+91', phoneNumber: '8595626824');
      final json = model.toJson();
      expect(json, {
        'countryCode': '+91',
        'phoneNumber': '8595626824',
      });
    });
  });
}
