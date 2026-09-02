import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String phone;
  final String name;
  final String about;
  final String profileImage;
  final bool isOnline;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.about,
    required this.profileImage,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [id, phone, name, about, profileImage, isOnline];
}
