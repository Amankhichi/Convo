import 'dart:convert';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/home/data/models/chat_summary_model.dart';

abstract class HomeLocalDataSource {
  Future<void> saveChats(List<ChatSummaryModel> chats);
  List<ChatSummaryModel> getCachedChats();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final LocalStorage _localStorage;

  HomeLocalDataSourceImpl(this._localStorage);

  @override
  Future<void> saveChats(List<ChatSummaryModel> chats) async {
    final jsonList = chats.map((c) => c.toJson()).toList();
    await _localStorage.setString('home_chats_list', jsonEncode(jsonList));
  }

  @override
  List<ChatSummaryModel> getCachedChats() {
    final jsonString = _localStorage.getString('home_chats_list');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => ChatSummaryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
