import 'package:equatable/equatable.dart';

class IceServerEntity extends Equatable {
  final List<String> urls;
  final String? username;
  final String? credential;

  const IceServerEntity({
    required this.urls,
    this.username,
    this.credential,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'urls': urls.length == 1 ? urls.first : urls,
    };
    if (username != null && username!.isNotEmpty) {
      map['username'] = username;
    }
    if (credential != null && credential!.isNotEmpty) {
      map['credential'] = credential;
    }
    return map;
  }

  @override
  List<Object?> get props => [urls, username, credential];
}
