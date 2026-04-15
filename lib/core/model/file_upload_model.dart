import 'package:equatable/equatable.dart';

class FileUploadModel extends Equatable {
  final int id;
  final String url;

  const FileUploadModel({
    required this.id,
    required this.url,
  });

  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
      id: json['id'] is int ? json['id'] : 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }

  FileUploadModel copyWith({
    int? id,
    String? url,
  }) {
    return FileUploadModel(
      id: id ?? this.id,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [id, url];
}