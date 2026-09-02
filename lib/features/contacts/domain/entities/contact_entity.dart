class ContactEntity {
  final int id;
  final String name;
  final String countryCode;
  final String phoneNumber;
  final String profileImage;
  final String about;
  final String status;
  final String lastSeen;
  final bool online;

  const ContactEntity({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.phoneNumber,
    required this.profileImage,
    required this.about,
    required this.status,
    required this.lastSeen,
    required this.online,
  });

  String get fullPhoneNumber => "$countryCode$phoneNumber";
}
