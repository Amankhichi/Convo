import 'package:convo/features/calling/domain/entities/ice_server.dart';

class IceServerModel extends IceServerEntity {
  const IceServerModel({
    required super.urls,
    super.username,
    super.credential,
  });

  factory IceServerModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedUrls = [];
    if (json['urls'] is List) {
      parsedUrls = (json['urls'] as List).map((e) => e.toString()).toList();
    } else if (json['urls'] is String) {
      parsedUrls = [json['urls'].toString()];
    } else if (json['url'] != null) {
      parsedUrls = [json['url'].toString()];
    }

    return IceServerModel(
      urls: parsedUrls,
      username: json['username']?.toString(),
      credential: json['credential']?.toString() ?? json['credential']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
