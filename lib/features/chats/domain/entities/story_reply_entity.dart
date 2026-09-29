class StoryReplyEntity {
  final String storyId;
  final String mediaUrl;
  final String mediaType; // 'IMAGE' or 'VIDEO'
  final String? createdAt;
  final bool isExpired;

  const StoryReplyEntity({
    required this.storyId,
    required this.mediaUrl,
    this.mediaType = 'IMAGE',
    this.createdAt,
    this.isExpired = false,
  });

  bool get computedIsExpired {
    if (isExpired) return true;
    if (createdAt == null || createdAt!.isEmpty) return false;
    try {
      final createdDate = DateTime.parse(createdAt!).toLocal();
      final now = DateTime.now();
      return now.difference(createdDate).inHours >= 24;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': createdAt,
      'isExpired': isExpired,
    };
  }

  factory StoryReplyEntity.fromJson(Map<String, dynamic> json) {
    return StoryReplyEntity(
      storyId: json['storyId']?.toString() ?? json['id']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? json['url']?.toString() ?? '',
      mediaType: json['mediaType']?.toString().toUpperCase() ?? 'IMAGE',
      createdAt: json['createdAt']?.toString(),
      isExpired: json['isExpired'] == true,
    );
  }
}
