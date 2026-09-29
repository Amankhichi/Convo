import 'package:convo/core/network/api_endpoints.dart';

class CallingConfig {
  static const String _envApiBaseUrl = String.fromEnvironment(
    'CALLING_API_BASE_URL',
    defaultValue: "",
  );

  static const String _envWsUrl = String.fromEnvironment(
    'CALLING_WS_URL',
    defaultValue: "",
  );

  static String get _defaultHost {
    try {
      final uri = Uri.parse(ApiEndpoints.baseUrl);
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {}
    return "192.168.0.117";
  }

  static String _sanitizeUrl(String rawUrl) {
    var clean = rawUrl.trim().replaceAll('#', '');
    if (clean.contains('#')) {
      clean = clean.split('#').first;
    }
    return clean;
  }

  // Helper method to obtain effective HTTP URL for calling backend
  static String get effectiveApiBaseUrl {
    String url = _envApiBaseUrl.isNotEmpty ? _envApiBaseUrl : "http://$_defaultHost:5001";
    url = _sanitizeUrl(url);
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  // Helper method to obtain effective WebSocket URL for calling backend
  static String get effectiveWsUrl {
    String url = _envWsUrl.isNotEmpty ? _envWsUrl : "ws://$_defaultHost:5001/ws/call";
    url = _sanitizeUrl(url);
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'ws://');
    } else if (url.startsWith('https://')) {
      url = url.replaceFirst('https://', 'wss://');
    }
    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      url = "ws://$url";
    }
    return url;
  }
}
