import '../../domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.nickname,
    required super.phone,
    required super.about,
    required super.profile,
    required super.online,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ??
          json['nickname']?.toString() ??
          'User',
      nickname: json['nickname']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobileNumber']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      profile: json['profile'] != null
          ? (json['profile'] is Map ? json['profile']['url']?.toString() ?? '' : json['profile'].toString())
          : (json['profileImage']?.toString() ?? ''),
      online: json['online'] == true || json['online'] == 1,
    );
  }

  factory UserModel.empty() {
    return const UserModel(
      id: 0,
      name: 'Unknown',
      nickname: 'Unknown',
      phone: '',
      about: '',
      profile: '',
      online: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'about': about,
      'profile': {'url': profile},
      'online': online,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      nickname: entity.nickname,
      phone: entity.phone,
      about: entity.about,
      profile: entity.profile,
      online: entity.online,
    );
  }
}
