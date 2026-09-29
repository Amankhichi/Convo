import 'dart:convert';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/stories/data/models/story_model.dart';

abstract class StoryLocalDataSource {
  Future<void> saveStoryGroups(List<UserStoryGroupModel> groups);
  List<UserStoryGroupModel> getCachedStoryGroups();
  Future<void> clearCache();
}

class StoryLocalDataSourceImpl implements StoryLocalDataSource {
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  StoryLocalDataSourceImpl(this._localStorage, this._secureStorage);

  String _getUserPrefix() {
    final userId = _secureStorage.getUserId();
    return userId > 0 ? "user_${userId}_" : "";
  }

  String get _storageKey => '${_getUserPrefix()}cached_user_stories';

  @override
  Future<void> saveStoryGroups(List<UserStoryGroupModel> groups) async {
    final jsonList = groups.map((g) => g.toJson()).toList();
    await _localStorage.setString(_storageKey, jsonEncode(jsonList));
  }

  @override
  List<UserStoryGroupModel> getCachedStoryGroups() {
    final jsonString = _localStorage.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => UserStoryGroupModel.fromJson(item as Map<String, dynamic>))
            .where((g) => g.activeStories.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> clearCache() async {
    await _localStorage.remove(_storageKey);
  }
}
