import 'package:convo/app/config/api_config.dart';
import 'package:convo/features/contacts/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.name,
    required super.countryCode,
    required super.phoneNumber,
    required super.profileImage,
    required super.about,
    required super.status,
    required super.lastSeen,
    required super.online,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['profileImage']?.toString() ?? '';
    return ContactModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '+91',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profileImage: ApiConfig.sanitizeUrl(rawImage),
      about: json['about']?.toString() ?? 'Hey there! I am using ConVo.',
      status: json['status']?.toString() ?? 'OFFLINE',
      lastSeen: json['lastSeen']?.toString() ?? '',
      online: json['online'] == true || json['online'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'about': about,
      'status': status,
      'lastSeen': lastSeen,
      'online': online,
    };
  }
}
