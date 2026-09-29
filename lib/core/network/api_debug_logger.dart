import 'dart:convert';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// ANSI Color formatting for terminal log readability
class _LogColor {
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String blue = '\x1B[34m';
  static const String yellow = '\x1B[33m';
  static const String red = '\x1B[31m';
  static const String cyan = '\x1B[36m';
  static const String magenta = '\x1B[35m';
  static const String bold = '\x1B[1m';
}

class ApiDebugLogger {
  static int _requestCounter = 0;
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  static final List<String> _sensitiveKeys = [
    'password',
    'pass',
    'otp',
    'secret',
    'secretkey',
  ];

  static String generateRequestId() {
    _requestCounter++;
    return 'API-${_requestCounter.toString().padLeft(3, '0')}';
  }

  static String _getCurrentUserId() {
    try {
      final storage = sl<SecureStorage>();
      final uid = storage.getUserId();
      return uid > 0 ? uid.toString() : 'ANONYMOUS / UNAUTHENTICATED';
    } catch (_) {
      return 'UNKNOWN';
    }
  }

  static String _getCurrentRawToken() {
    try {
      final storage = sl<SecureStorage>();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (_) {}
    return 'NO TOKEN STORED';
  }

  static String _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return _LogColor.green;
      case 'POST':
        return _LogColor.blue;
      case 'PUT':
      case 'PATCH':
        return _LogColor.yellow;
      case 'DELETE':
        return _LogColor.red;
      default:
        return _LogColor.magenta;
    }
  }

  static void logRequest({
    required String requestId,
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    dynamic body,
    Map<String, String>? queryParameters,
  }) {
    if (!kDebugMode) return;

    final now = _timeFormat.format(DateTime.now());
    final userId = _getCurrentUserId();
    final rawToken = headers['Authorization'] ?? headers['authorization'] ?? _getCurrentRawToken();
    final color = _getMethodColor(method);
    final processedHeaders = _processHeaders(headers);
    final queryParams = queryParameters ?? (uri.queryParameters.isNotEmpty ? uri.queryParameters : null);
    final maskedQueryParams = queryParams != null ? _maskMap(queryParams) : null;
    final maskedBody = _maskData(body);

    final buffer = StringBuffer();
    buffer.writeln('${_LogColor.bold}$color════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}$color🚀 [$requestId] HTTP $method REQUEST${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}$color════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}METHOD       :${_LogColor.reset} $color$method${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}ENDPOINT URL :${_LogColor.reset} $uri');
    buffer.writeln('${_LogColor.cyan}USER/ENTITY  :${_LogColor.reset} ID: $userId');
    buffer.writeln('${_LogColor.cyan}RAW TOKEN    :${_LogColor.reset} $rawToken');
    buffer.writeln('${_LogColor.cyan}TIME         :${_LogColor.reset} $now');

    buffer.writeln();
    buffer.writeln('${_LogColor.cyan}HEADERS:${_LogColor.reset}');
    buffer.writeln(_prettyPrintJson(processedHeaders));

    if (maskedQueryParams != null && maskedQueryParams.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('${_LogColor.cyan}QUERY PARAMETERS:${_LogColor.reset}');
      buffer.writeln(_prettyPrintJson(maskedQueryParams));
    }

    if (maskedBody != null) {
      buffer.writeln();
      buffer.writeln('${_LogColor.cyan}REQUEST PAYLOAD / BODY:${_LogColor.reset}');
      buffer.writeln(_prettyPrintJson(maskedBody));
    }

    buffer.writeln('${_LogColor.bold}$color════════════════════════════════════════════${_LogColor.reset}');
    debugPrint(buffer.toString());
  }

  static void logResponse({
    required String requestId,
    required String method,
    required Uri uri,
    required int statusCode,
    required int durationMs,
    dynamic responseBody,
  }) {
    if (!kDebugMode) return;

    final now = _timeFormat.format(DateTime.now());
    final userId = _getCurrentUserId();
    final rawToken = _getCurrentRawToken();
    final statusColor = (statusCode >= 200 && statusCode < 300) ? _LogColor.green : _LogColor.red;
    final maskedResponseBody = _maskData(responseBody);

    final buffer = StringBuffer();
    buffer.writeln('${_LogColor.bold}$statusColor════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}$statusColor✅ [$requestId] HTTP $method RESPONSE ($statusCode)${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}$statusColor════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}METHOD       :${_LogColor.reset} $method');
    buffer.writeln('${_LogColor.cyan}ENDPOINT URL :${_LogColor.reset} $uri');
    buffer.writeln('${_LogColor.cyan}USER/ENTITY  :${_LogColor.reset} ID: $userId');
    buffer.writeln('${_LogColor.cyan}RAW TOKEN    :${_LogColor.reset} $rawToken');
    buffer.writeln('${_LogColor.cyan}STATUS CODE  :${_LogColor.reset} $statusColor$statusCode${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}DURATION     :${_LogColor.reset} ${durationMs}ms');
    buffer.writeln('${_LogColor.cyan}TIME         :${_LogColor.reset} $now');
    buffer.writeln();

    buffer.writeln('${_LogColor.cyan}RESPONSE DATA:${_LogColor.reset}');
    buffer.writeln(_prettyPrintJson(maskedResponseBody));
    buffer.writeln('${_LogColor.bold}$statusColor════════════════════════════════════════════${_LogColor.reset}');
    debugPrint(buffer.toString());
  }

  static void logError({
    required String requestId,
    required String method,
    required Uri uri,
    int? statusCode,
    required int durationMs,
    dynamic requestBody,
    dynamic errorResponse,
    String? errorMessage,
    dynamic exception,
  }) {
    if (!kDebugMode) return;

    final now = _timeFormat.format(DateTime.now());
    final userId = _getCurrentUserId();
    final rawToken = _getCurrentRawToken();
    final maskedRequestBody = _maskData(requestBody);
    final maskedErrorResponse = _maskData(errorResponse);

    final buffer = StringBuffer();
    buffer.writeln('${_LogColor.bold}${_LogColor.red}════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}${_LogColor.red}❌ [$requestId] HTTP $method ERROR${_LogColor.reset}');
    buffer.writeln('${_LogColor.bold}${_LogColor.red}════════════════════════════════════════════${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}METHOD       :${_LogColor.reset} ${_LogColor.red}$method${_LogColor.reset}');
    buffer.writeln('${_LogColor.cyan}ENDPOINT URL :${_LogColor.reset} $uri');
    buffer.writeln('${_LogColor.cyan}USER/ENTITY  :${_LogColor.reset} ID: $userId');
    buffer.writeln('${_LogColor.cyan}RAW TOKEN    :${_LogColor.reset} $rawToken');
    if (statusCode != null) {
      buffer.writeln('${_LogColor.cyan}STATUS CODE  :${_LogColor.reset} ${_LogColor.red}$statusCode${_LogColor.reset}');
    }
    buffer.writeln('${_LogColor.cyan}DURATION     :${_LogColor.reset} ${durationMs}ms');
    buffer.writeln('${_LogColor.cyan}TIME         :${_LogColor.reset} $now');

    if (maskedRequestBody != null) {
      buffer.writeln();
      buffer.writeln('${_LogColor.cyan}REQUEST PAYLOAD / BODY:${_LogColor.reset}');
      buffer.writeln(_prettyPrintJson(maskedRequestBody));
    }

    if (maskedErrorResponse != null) {
      buffer.writeln();
      buffer.writeln('${_LogColor.red}ERROR RESPONSE:${_LogColor.reset}');
      buffer.writeln(_prettyPrintJson(maskedErrorResponse));
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('${_LogColor.red}ERROR MESSAGE:${_LogColor.reset} $errorMessage');
    }

    if (exception != null) {
      buffer.writeln();
      buffer.writeln('${_LogColor.red}EXCEPTION:${_LogColor.reset} $exception');
    }

    buffer.writeln('${_LogColor.bold}${_LogColor.red}════════════════════════════════════════════${_LogColor.reset}');
    debugPrint(buffer.toString());
  }

  static Map<String, dynamic> _processHeaders(Map<dynamic, dynamic> map) {
    final Map<String, dynamic> result = {};
    map.forEach((key, value) {
      final strKey = key.toString();
      result[strKey] = value?.toString() ?? '';
    });
    return result;
  }

  static Map<String, dynamic> _maskMap(Map<dynamic, dynamic> map) {
    final Map<String, dynamic> result = {};
    map.forEach((key, value) {
      final strKey = key.toString();
      if (_isSensitiveKey(strKey)) {
        result[strKey] = '***MASKED***';
      } else {
        result[strKey] = _maskData(value);
      }
    });
    return result;
  }

  static dynamic _maskData(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return _maskMap(data);
    } else if (data is List) {
      return data.map((item) => _maskData(item)).toList();
    } else if (data is String) {
      if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
        try {
          final decoded = jsonDecode(data);
          return _maskData(decoded);
        } catch (_) {
          return data;
        }
      }
      return data;
    }
    return data;
  }

  static bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    return _sensitiveKeys.any((s) => lower.contains(s.replaceAll('_', '').replaceAll('-', '')));
  }

  static String _prettyPrintJson(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is String) {
        if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
          final decoded = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        }
        return data;
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
