import 'package:convo/features/calling/domain/entities/call_user.dart';

class CallUserModel extends CallUser {
  const CallUserModel({
    required super.id,
    required super.name,
    super.phone,
    super.profileImage,
  });

  factory CallUserModel.fromJson(Map<String, dynamic> json) {
    return CallUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ??
          json['username']?.toString() ??
          json['callerName']?.toString() ??
          'Unknown User',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ??
          json['profile']?.toString() ??
          json['avatar']?.toString() ??
          json['callerAvatar']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
    };
  }
}
