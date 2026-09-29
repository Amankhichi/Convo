abstract class DeviceTokenRepository {
  Future<bool> registerDeviceToken(String token, String platform);
  Future<bool> unregisterDeviceToken(String token);
}
