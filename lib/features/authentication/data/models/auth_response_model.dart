import 'package:convo/features/authentication/domain/entities/user_entity.dart';

class VerifyOtpResponseModel {
  final String token;
  final bool isNewUser;
  final UserEntity? user;

  const VerifyOtpResponseModel({
    required this.token,
    required this.isNewUser,
    this.user,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = (json["data"] is Map<String, dynamic>)
        ? json["data"] as Map<String, dynamic>
        : json;

    final token = dataMap["token"]?.toString() ?? json["token"]?.toString() ?? "";
    
    final rawIsNewUser = dataMap["isNewUser"] ?? json["isNewUser"];
    bool isNewUser = false;
    if (rawIsNewUser is bool) {
      isNewUser = rawIsNewUser;
    } else if (rawIsNewUser is String) {
      isNewUser = rawIsNewUser.toLowerCase() == 'true' || rawIsNewUser == '1';
    } else if (rawIsNewUser is num) {
      isNewUser = rawIsNewUser == 1;
    }

    UserEntity? user;
    final userData = dataMap["user"] ?? json["user"];
    if (userData != null && userData is Map<String, dynamic>) {
      user = UserEntity(
        id: userData["id"] is int ? userData["id"] : int.tryParse(userData["id"].toString()) ?? 0,
        phone: userData["phoneNumber"]?.toString() ?? userData["phone"]?.toString() ?? "",
        name: userData["name"]?.toString() ?? "",
        about: userData["about"]?.toString() ?? "",
        profileImage: userData["profileImage"]?.toString() ?? userData["profile"]?.toString() ?? "",
        isOnline: userData["status"]?.toString() == "ONLINE",
      );
    }

    return VerifyOtpResponseModel(
      token: token,
      isNewUser: isNewUser,
      user: user,
    );
  }
}
