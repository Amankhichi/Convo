import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String nickname;
  final String phone;
  final String about;
  final String profile;
  final bool online;

  const UserEntity({
    required this.id,
    required this.name,
    required this.nickname,
    required this.phone,
    required this.about,
    required this.profile,
    required this.online,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? nickname,
    String? phone,
    String? about,
    String? profile,
    bool? online,
  }) {
    return UserEntity(
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
  List<Object?> get props => [id, name, nickname, phone, about, profile, online];
}
