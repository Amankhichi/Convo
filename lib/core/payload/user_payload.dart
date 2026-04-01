class UserPayload {
  // final String name;
  final String phone;
  final String about;
  final String nickName;
  final String profile;
  final bool online;

  UserPayload({
    // required this.name,
    required this.nickName,
    required this.phone,
    required this.about,
    required this.profile,
    required this.online,
  });

  Map<String, dynamic> toJson() => {
        // "name": name,
        "nickName": nickName,
        "phone": phone,
        "about": about,
        "profile": profile,
        "online":online?1:0,
      };

  // ✅ Convert JSON → Dart object
  factory UserPayload.fromJson(Map<String, dynamic> json) => UserPayload(
        // name: json["name"],
        nickName: json["nickName"],
        phone: json["phone"],
        about: json["about"],
        profile: json["profile"],
        online: json['online'],
      );
}



