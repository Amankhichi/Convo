import 'user_model.dart';

class VerifyOtpResponseModel {
  final bool success;
  final bool newUser;
  final String? token;
  final UserModel? user;

  VerifyOtpResponseModel({
    required this.success,
    required this.newUser,
    this.token,
    this.user,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] as bool? ?? false,
      newUser: json['newUser'] as bool? ?? false,
      token: json['token']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'newUser': newUser,
      'token': token,
      'user': user?.toJson(),
    };
  }
}
