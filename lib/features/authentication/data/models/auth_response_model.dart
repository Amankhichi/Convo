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

    final token = dataMap["token"]?.toString() ??
        dataMap["accessToken"]?.toString() ??
        dataMap["jwt"]?.toString() ??
        dataMap["jwtToken"]?.toString() ??
        dataMap["access_token"]?.toString() ??
        dataMap["auth_token"]?.toString() ??
        json["token"]?.toString() ??
        json["accessToken"]?.toString() ??
        json["jwt"]?.toString() ??
        json["jwtToken"]?.toString() ??
        json["access_token"]?.toString() ??
        json["auth_token"]?.toString() ??
        "";

    final rawIsNewUser = dataMap["isNewUser"] ?? dataMap["newUser"] ?? json["isNewUser"] ?? json["newUser"];
    bool isNewUser = false;
    if (rawIsNewUser is bool) {
      isNewUser = rawIsNewUser;
    } else if (rawIsNewUser is String) {
      isNewUser = rawIsNewUser.toLowerCase() == 'true' || rawIsNewUser == '1';
    } else if (rawIsNewUser is num) {
      isNewUser = rawIsNewUser == 1;
    }

    UserEntity? user;
    final userData = dataMap["user"] ?? dataMap["profile"] ?? json["user"] ?? json["profile"];
    if (userData != null && userData is Map<String, dynamic>) {
      user = UserEntity(
        id: userData["id"] is int ? userData["id"] : int.tryParse(userData["id"]?.toString() ?? '0') ?? 0,
        phone: userData["phoneNumber"]?.toString() ?? userData["phone"]?.toString() ?? "",
        name: userData["name"]?.toString() ?? "",
        about: userData["about"]?.toString() ?? "",
        profileImage: userData["profileImage"]?.toString() ?? userData["profile"]?.toString() ?? userData["image"]?.toString() ?? "",
        isOnline: userData["status"]?.toString().toUpperCase() == "ONLINE" || userData["online"] == true,
      );
    } else if (!isNewUser && (dataMap.containsKey("id") || json.containsKey("id"))) {
      final rootMap = dataMap.containsKey("id") ? dataMap : json;
      user = UserEntity(
        id: rootMap["id"] is int ? rootMap["id"] : int.tryParse(rootMap["id"]?.toString() ?? '0') ?? 0,
        phone: rootMap["phoneNumber"]?.toString() ?? rootMap["phone"]?.toString() ?? "",
        name: rootMap["name"]?.toString() ?? "",
        about: rootMap["about"]?.toString() ?? "",
        profileImage: rootMap["profileImage"]?.toString() ?? rootMap["profile"]?.toString() ?? rootMap["image"]?.toString() ?? "",
        isOnline: rootMap["status"]?.toString().toUpperCase() == "ONLINE" || rootMap["online"] == true,
      );
    }

    // If name is empty, treat user as new user so they can complete profile setup
    if (user != null && user.name.trim().isEmpty) {
      isNewUser = true;
    }

    return VerifyOtpResponseModel(
      token: token,
      isNewUser: isNewUser,
      user: user,
    );
  }
}
