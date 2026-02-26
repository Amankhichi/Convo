import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String nickName;
  final String phone;
  final String about;
  final String lotti;
  final bool online;

  const UserModel({
    required this.id,
    required this.name,
    required this.nickName,
    required this.phone,
    required this.about,
    required this.lotti,
    required this.online,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      lotti: json['lotti']?.toString() ?? '',
      online: json['online'] == true || json['online'] == 1,
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? nickName,
    String? phone,
    String? about,
    String? lotti,
    bool? online,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      phone: phone ?? this.phone,
      about: about ?? this.about,
      lotti: lotti ?? this.lotti,
      online: online ?? this.online,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nickName,
        phone,
        about,
        lotti,
        online,
      ];
}