import 'package:dio/dio.dart';
import '../storage/storage_service.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageWrapper _secureStorage;

  ApiInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    final token = await _secureStorage.read("token");
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
}
