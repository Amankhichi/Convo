import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ApiDebugLogger {
  static int _requestCounter = 0;
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  static final List<String> _sensitiveKeys = [
    'authorization',
    'auth',
    'password',
    'pass',
    'otp',
    'token',
    'accesstoken',
    'refreshtoken',
    'access_token',
    'refresh_token',
    'apikey',
    'api_key',
    'secret',
    'secretkey',
    'cookie',
  ];

  static String generateRequestId() {
    _requestCounter++;
    return 'API-${_requestCounter.toString().padLeft(3, '0')}';
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
    final maskedHeaders = _maskMap(headers);
    final queryParams = queryParameters ?? (uri.queryParameters.isNotEmpty ? uri.queryParameters : null);
    final maskedQueryParams = queryParams != null ? _maskMap(queryParams) : null;
    final maskedBody = _maskData(body);

    final buffer = StringBuffer();
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('🚀 [$requestId] API REQUEST');
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('METHOD   : $method');
    buffer.writeln('URL      : $uri');
    buffer.writeln('TIME     : $now');
    buffer.writeln();

    buffer.writeln('HEADERS:');
    buffer.writeln(_prettyPrintJson(maskedHeaders));

    if (maskedQueryParams != null && maskedQueryParams.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('QUERY PARAMETERS:');
      buffer.writeln(_prettyPrintJson(maskedQueryParams));
    }

    if (maskedBody != null) {
      buffer.writeln();
      buffer.writeln('REQUEST BODY:');
      buffer.writeln(_prettyPrintJson(maskedBody));
    }

    buffer.writeln('════════════════════════════════════════════');
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
    final maskedResponseBody = _maskData(responseBody);

    final buffer = StringBuffer();
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('✅ [$requestId] API RESPONSE');
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('METHOD   : $method');
    buffer.writeln('URL      : $uri');
    buffer.writeln('STATUS   : $statusCode');
    buffer.writeln('DURATION : $durationMs ms');
    buffer.writeln('TIME     : $now');
    buffer.writeln();

    buffer.writeln('RESPONSE DATA:');
    buffer.writeln(_prettyPrintJson(maskedResponseBody));
    buffer.writeln('════════════════════════════════════════════');
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
    final maskedRequestBody = _maskData(requestBody);
    final maskedErrorResponse = _maskData(errorResponse);

    final buffer = StringBuffer();
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('❌ [$requestId] API ERROR');
    buffer.writeln('════════════════════════════════════════════');
    buffer.writeln('METHOD   : $method');
    buffer.writeln('URL      : $uri');
    if (statusCode != null) {
      buffer.writeln('STATUS   : $statusCode');
    }
    buffer.writeln('DURATION : $durationMs ms');
    buffer.writeln('TIME     : $now');

    if (maskedRequestBody != null) {
      buffer.writeln();
      buffer.writeln('REQUEST BODY:');
      buffer.writeln(_prettyPrintJson(maskedRequestBody));
    }

    if (maskedErrorResponse != null) {
      buffer.writeln();
      buffer.writeln('ERROR RESPONSE:');
      buffer.writeln(_prettyPrintJson(maskedErrorResponse));
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('ERROR MESSAGE: $errorMessage');
    }

    if (exception != null) {
      buffer.writeln();
      buffer.writeln('EXCEPTION: $exception');
    }

    buffer.writeln('════════════════════════════════════════════');
    debugPrint(buffer.toString());
  }

  static Map<String, dynamic> _maskMap(Map<dynamic, dynamic> map) {
    final Map<String, dynamic> result = {};
    map.forEach((key, value) {
      final strKey = key.toString();
      if (_isSensitiveKey(strKey)) {
        if (strKey.toLowerCase() == 'authorization' && value is String && value.startsWith('Bearer ')) {
          result[strKey] = 'Bearer ***MASKED***';
        } else {
          result[strKey] = '***MASKED***';
        }
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
