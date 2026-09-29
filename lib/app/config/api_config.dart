import 'package:convo/core/network/api_endpoints.dart';

class ApiConfig {
  static String get baseUrl => ApiEndpoints.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 15);

  static const String wsEndpoint = "/ws/websocket";
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws') + wsEndpoint;

  static String sanitizeUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    var sanitized = url
        .replaceAll('http://localhost:7000', baseUrl)
        .replaceAll('https://localhost:7000', baseUrl)
        .replaceAll('http://127.0.0.1:7000', baseUrl)
        .replaceAll('https://127.0.0.1:7000', baseUrl);

    final uri = Uri.tryParse(sanitized);
    if (uri != null && uri.host.isNotEmpty && uri.host.startsWith('192.168.')) {
      final targetUri = Uri.parse(baseUrl);
      sanitized = uri.replace(host: targetUri.host, port: targetUri.port).toString();
    }
    return sanitized;
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
