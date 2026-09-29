import 'package:equatable/equatable.dart';

class CallUser extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String profileImage;

  const CallUser({
    required this.id,
    required this.name,
    this.phone = '',
    this.profileImage = '',
  });

  @override
  List<Object?> get props => [id, name, phone, profileImage];
}
