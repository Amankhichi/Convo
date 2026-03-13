class GroupTablePayload {
  final String? createdAt;
  final int userId;
  final String name;
  final String? url;
  final String? bio;

  GroupTablePayload({
    this.createdAt,
    required this.userId,
   required this.name,
    this.url,
    this.bio,
  });

  factory GroupTablePayload.fromJson(Map<String, dynamic> json) {
    return GroupTablePayload(
      createdAt: json['created_at'],
      userId:json['userId'],
      name: json['name'],
      url: json['url'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "created_at": createdAt,
      "userId": userId,
      "name": name,
      "url": url,
      "bio": bio,
    };
  }
}