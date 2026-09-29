import 'package:convo/core/network/api_client.dart';
import 'package:convo/features/stories/data/models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<List<UserStoryGroupModel>> fetchFeed({int page = 0, int limit = 20});
  Future<UserStoryGroupModel?> fetchMyStories();
  Future<StoryItemModel> uploadStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
  });
  Future<bool> markStoryViewed(dynamic storyId);
  Future<int> fetchViewCount(dynamic storyId);
  Future<List<StoryViewerModel>> fetchViewers(dynamic storyId, {int page = 0, int limit = 20});
  Future<bool> deleteStory(dynamic storyId);
  Future<bool> likeStory(dynamic storyId);
  Future<bool> unlikeStory(dynamic storyId);
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final ApiClient _apiClient;

  StoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UserStoryGroupModel>> fetchFeed({int page = 0, int limit = 20}) async {
    final res = await _apiClient.get(
      "/api/stories/feed",
      queryParameters: {"page": page.toString(), "limit": limit.toString()},
    );

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to fetch story feed");
      }
      final data = res["data"] ?? res["content"] ?? res["stories"];
      if (data is List) {
        return data.map((item) => UserStoryGroupModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } else if (res is List) {
      return res.map((item) => UserStoryGroupModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    return [];
  }

  @override
  Future<UserStoryGroupModel?> fetchMyStories() async {
    final res = await _apiClient.get("/api/stories/me");

    if (res is Map<String, dynamic>) {
      final data = res["data"] ?? res;
      if (data is Map<String, dynamic>) {
        return UserStoryGroupModel.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return UserStoryGroupModel(
          userId: 0,
          userName: "My Story",
          userImage: "",
          stories: data.map((item) => StoryItemModel.fromJson(item as Map<String, dynamic>)).toList(),
        );
      }
    } else if (res is List) {
      return UserStoryGroupModel(
        userId: 0,
        userName: "My Story",
        userImage: "",
        stories: res.map((item) => StoryItemModel.fromJson(item as Map<String, dynamic>)).toList(),
      );
    }
    return null;
  }

  @override
  Future<StoryItemModel> uploadStory({
    required String mediaUrl,
    String mediaType = 'IMAGE',
  }) async {
    final body = {
      "mediaUrl": mediaUrl,
      "mediaType": mediaType.toUpperCase(),
    };

    final res = await _apiClient.post("/api/stories/upload", body: body);

    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to upload story");
      }
      final data = res["data"] ?? res;
      if (data is Map<String, dynamic>) {
        return StoryItemModel.fromJson(data);
      }
    }
    return StoryItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<bool> markStoryViewed(dynamic storyId) async {
    final numId = storyId is int ? storyId : int.tryParse(storyId.toString()) ?? 0;
    final res = await _apiClient.post("/api/stories/view", body: {"storyId": numId});
    if (res is Map<String, dynamic>) {
      return res["success"] != false;
    }
    return res != null;
  }

  @override
  Future<int> fetchViewCount(dynamic storyId) async {
    final res = await _apiClient.get("/api/stories/$storyId/views/count");
    if (res is Map<String, dynamic>) {
      final data = res["data"];
      if (data is Map<String, dynamic>) {
        final count = data["viewCount"] ?? data["count"];
        if (count is int) return count;
        return int.tryParse(count?.toString() ?? '0') ?? 0;
      }
      final count = res["data"] ?? res["count"] ?? res["viewCount"];
      if (count is int) return count;
      return int.tryParse(count?.toString() ?? '0') ?? 0;
    } else if (res is num) {
      return res.toInt();
    }
    return 0;
  }

  @override
  Future<List<StoryViewerModel>> fetchViewers(dynamic storyId, {int page = 0, int limit = 20}) async {
    final res = await _apiClient.get(
      "/api/stories/$storyId/views",
      queryParameters: {"page": page.toString(), "limit": limit.toString()},
    );

    if (res is Map<String, dynamic>) {
      final data = res["data"];
      if (data is Map<String, dynamic> && data["viewers"] is List) {
        return (data["viewers"] as List)
            .map((v) => StoryViewerModel.fromJson(v as Map<String, dynamic>))
            .toList();
      }
      final raw = res["data"] ?? res["content"] ?? res["viewers"];
      if (raw is List) {
        return raw.map((v) => StoryViewerModel.fromJson(v as Map<String, dynamic>)).toList();
      }
    } else if (res is List) {
      return res.map((v) => StoryViewerModel.fromJson(v as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<bool> deleteStory(dynamic storyId) async {
    final res = await _apiClient.delete("/api/stories/$storyId");
    if (res is Map<String, dynamic>) {
      return res["success"] != false;
    }
    return res != null;
  }

  @override
  Future<bool> likeStory(dynamic storyId) async {
    final res = await _apiClient.post("/api/stories/$storyId/like");
    if (res is Map<String, dynamic>) {
      return res["success"] != false;
    }
    return res != null;
  }

  @override
  Future<bool> unlikeStory(dynamic storyId) async {
    final res = await _apiClient.delete("/api/stories/$storyId/like");
    if (res is Map<String, dynamic>) {
      return res["success"] != false;
    }
    return res != null;
  }
}
