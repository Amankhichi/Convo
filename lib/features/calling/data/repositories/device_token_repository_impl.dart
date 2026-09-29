import 'dart:developer' as developer;
import 'package:convo/app/config/calling_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/calling/domain/repositories/device_token_repository.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  final ApiClient _apiClient;

  DeviceTokenRepositoryImpl(this._apiClient);

  @override
  Future<bool> registerDeviceToken(String token, String platform) async {
    if (token.isEmpty) return false;
    final baseUrl = CallingConfig.effectiveApiBaseUrl;
    final url = '$baseUrl/api/calls/device-token';

    try {
      _log("Registering device token with backend: platform=$platform");
      final response = await _apiClient.post(url, body: {
        'token': token,
        'platform': platform,
      });
      return response != null;
    } catch (e) {
      _log("Device token registration fallback/error: $e");
      // Return true to avoid blocking app flow if endpoint is pending on backend
      return true;
    }
  }

  @override
  Future<bool> unregisterDeviceToken(String token) async {
    if (token.isEmpty) return false;
    final baseUrl = CallingConfig.effectiveApiBaseUrl;
    final url = '$baseUrl/api/calls/device-token';

    try {
      _log("Unregistering device token from backend");
      final response = await _apiClient.delete('$url?token=$token');
      return response != null;
    } catch (e) {
      _log("Device token unregistration error: $e");
      return false;
    }
  }

  void _log(String message) {
    developer.log("[DeviceTokenRepository] $message");
  }
}
