class RequestOtpResponse {
  final String? message;
  final bool success;

  RequestOtpResponse({
    this.message,
    this.success = true,
  });

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      message: json['message']?.toString(),
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}
