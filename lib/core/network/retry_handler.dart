import 'package:dio/dio.dart';

class RetryHandler {
  final Dio dio;

  RetryHandler({required this.dio});

  Future<Response> retry(RequestOptions requestOptions) {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
