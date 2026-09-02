class ApiConfig {
  static const String baseUrl = "http://192.168.0.117:7000";
  static const Duration timeoutDuration = Duration(seconds: 15);

  static const String wsEndpoint = "/ws/websocket";
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws') + wsEndpoint;

  static String sanitizeUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    return url
        .replaceFirst('http://localhost:7000', baseUrl)
        .replaceFirst('https://localhost:7000', baseUrl)
        .replaceFirst('http://127.0.0.1:7000', baseUrl)
        .replaceFirst('https://127.0.0.1:7000', baseUrl);
  }

  static const String requestOtp = "/api/auth/request-otp";
  static const String verifyOtp = "/api/auth/verify-otp";
  static const String profile = "/api/users/profile";
  static const String deleteUser = "/api/users/me";
  static const String syncContacts = "/api/contacts/sync";
  static const String chats = "/api/chats";
  static const String messages = "/api/messages";
  static const String mediaUpload = "/api/media/upload";
  static const String heartbeat = "/api/users/presence/heartbeat";
}
