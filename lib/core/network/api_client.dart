import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_constants.dart';
import 'api_exceptions.dart';
import 'api_interceptor.dart';
import 'logger_interceptor.dart';
import '../storage/storage_service.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio, required SecureStorageWrapper secureStorage}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiEndpoints.baseUrl
      ..connectTimeout = const Duration(
        milliseconds: ApiConstants.connectTimeout,
      )
      ..receiveTimeout = const Duration(
        milliseconds: ApiConstants.receiveTimeout,
      )
      ..sendTimeout = const Duration(milliseconds: ApiConstants.sendTimeout);

    _dio.interceptors.addAll([ApiInterceptor(secureStorage), LoggerInterceptor()]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  ApiException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: "No internet connection or connection timed out",
      );
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String errorMessage = "Something went wrong";

    if (data is Map && data.containsKey('message')) {
      errorMessage = data['message'];
    } else if (e.message != null) {
      errorMessage = e.message!;
    }

    if (statusCode == 400 || statusCode == 422) {
      return ValidationException(message: errorMessage, statusCode: statusCode);
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerException(message: errorMessage, statusCode: statusCode);
    }

    return ApiException(message: errorMessage, statusCode: statusCode);
  }
}
