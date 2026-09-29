import 'dart:convert';
import 'dart:typed_data';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/errors/app_exception.dart';
import 'package:convo/core/network/api_debug_logger.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/core/utils/logger.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final SecureStorage _secureStorage;

  ApiClient(this._client, this._secureStorage);

  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };
    final token = _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final clean = token.trim().replaceAll(RegExp(r'[\s\r\n\t]+'), '').replaceAll('#', '');
      final cleanToken = clean.contains('#') ? clean.split('#').first : clean;
      headers["Authorization"] = "Bearer $cleanToken";
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final cleanPath = path.trim().replaceAll('#', '').split('#').first;
    final isAbsolute = cleanPath.startsWith('http://') || cleanPath.startsWith('https://');
    final baseUri = (isAbsolute ? Uri.parse(cleanPath) : Uri.parse("${ApiConfig.baseUrl}$cleanPath")).removeFragment();
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return baseUri.replace(queryParameters: queryParameters).removeFragment();
    }
    return baseUri;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "GET",
      uri: uri,
      headers: headers,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client.get(uri, headers: headers).timeout(ApiConfig.timeoutDuration);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "GET",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "GET",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        exception: e,
      );
      AppLogger.e("GET Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  Future<dynamic> post(String path, {dynamic body, Map<String, String>? queryParameters}) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "POST",
      uri: uri,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .post(uri, headers: headers, body: encodedBody)
          .timeout(ApiConfig.timeoutDuration);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "POST",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "POST",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
        exception: e,
      );
      AppLogger.e("POST Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  Future<dynamic> put(String path, {dynamic body, Map<String, String>? queryParameters}) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "PUT",
      uri: uri,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .put(uri, headers: headers, body: encodedBody)
          .timeout(ApiConfig.timeoutDuration);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "PUT",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "PUT",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
        exception: e,
      );
      AppLogger.e("PUT Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  Future<dynamic> patch(String path, {dynamic body, Map<String, String>? queryParameters}) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final encodedBody = body != null ? jsonEncode(body) : null;
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "PATCH",
      uri: uri,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(ApiConfig.timeoutDuration);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "PATCH",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "PATCH",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        requestBody: body,
        exception: e,
      );
      AppLogger.e("PATCH Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  Future<dynamic> delete(String path, {Map<String, String>? queryParameters}) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "DELETE",
      uri: uri,
      headers: headers,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client.delete(uri, headers: headers).timeout(ApiConfig.timeoutDuration);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "DELETE",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "DELETE",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        exception: e,
      );
      AppLogger.e("DELETE Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> queryParameters,
    Uint8List? fileBytes,
    String fileFieldName = "image",
    String filename = "profile.jpg",
  }) async {
    final requestId = ApiDebugLogger.generateRequestId();
    final uri = _buildUri(path, queryParameters);
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    ApiDebugLogger.logRequest(
      requestId: requestId,
      method: "POST (Multipart)",
      uri: uri,
      headers: headers,
      body: {"fileField": fileFieldName, "filename": filename, "fileBytesLength": fileBytes?.length ?? 0},
      queryParameters: queryParameters,
    );

    try {
      final request = http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);

      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: filename,
          ),
        );
      }

      final streamedRes = await request.send().timeout(ApiConfig.timeoutDuration);
      final response = await http.Response.fromStream(streamedRes);
      stopwatch.stop();

      return _handleResponse(
        response,
        requestId: requestId,
        method: "POST (Multipart)",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      ApiDebugLogger.logError(
        requestId: requestId,
        method: "POST (Multipart)",
        uri: uri,
        durationMs: stopwatch.elapsedMilliseconds,
        exception: e,
      );
      AppLogger.e("Multipart Error: $e");
      if (e is AuthException || e is ServerException) rethrow;
      throw const NetworkException();
    }
  }

  dynamic _handleResponse(
    http.Response response, {
    required String requestId,
    required String method,
    required Uri uri,
    required int durationMs,
    dynamic requestBody,
  }) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (isSuccess) {
      ApiDebugLogger.logResponse(
        requestId: requestId,
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        durationMs: durationMs,
        responseBody: response.body,
      );

      if (response.body.isEmpty) return true;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return true;
      }
    } else {
      ApiDebugLogger.logError(
        requestId: requestId,
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        durationMs: durationMs,
        requestBody: requestBody,
        errorResponse: response.body,
        errorMessage: response.reasonPhrase,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException("Unauthorized request.", response.statusCode);
      } else {
        throw ServerException("Server response error", response.statusCode);
      }
    }
  }
}
