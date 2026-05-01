import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String nickname;
  final String phone;
  final String about;
  final String profile;
  final bool online;

  const UserModel({
    required this.id,
    required this.name,
    required this.nickname,
    required this.phone,
    required this.about,
    required this.profile,
    required this.online,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,

      /// ✅ fallback name
      name: json['name']?.toString() ??
          json['nickname']?.toString() ??
          'User',

      nickname: json['nickname']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      about: json['about']?.toString() ?? '',

      /// ✅ safe profile parsing
      profile: json['profile'] != null
          ? json['profile']['url']?.toString() ?? ''
          : '',

      online: json['online'] == true || json['online'] == 1,
    );
  }

  /// ✅ FIX: empty fallback user
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

  UserModel copyWith({
    int? id,
    String? name,
    String? nickname,
    String? phone,
    String? about,
    String? profile,
    bool? online,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      about: about ?? this.about,
      profile: profile ?? this.profile,
      online: online ?? this.online,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nickname,
        phone,
        about,
        profile,
        online,
      ];
}