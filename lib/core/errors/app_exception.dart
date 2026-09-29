class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => "AppException: $message (statusCode: $statusCode)";
}

class NetworkException extends AppException {
  const NetworkException([String message = "No internet connection available."])
      : super(message);
}

class ServerException extends AppException {
  const ServerException([String message = "Server error occurred.", int? statusCode])
      : super(message, statusCode: statusCode);
}

class AuthException extends AppException {
  const AuthException([String message = "Authentication failed.", int? statusCode])
      : super(message, statusCode: statusCode);
}
