import 'dart:convert';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/chats/data/models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<void> saveChatId(int targetUserId, int chatId);
  int? getChatId(int targetUserId);
  Future<void> saveMessages(int chatId, List<MessageModel> messages);
  List<MessageModel> getCachedMessages(int chatId);
  Future<void> saveChatUserProfile(int chatId, Map<String, dynamic> userProfile);
  Map<String, dynamic>? getChatUserProfile(int chatId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  ChatLocalDataSourceImpl(this._localStorage, this._secureStorage);

  String _getUserPrefix() {
    final userId = _secureStorage.getUserId();
    return userId > 0 ? "user_${userId}_" : "";
  }

  @override
  Future<void> saveChatId(int targetUserId, int chatId) async {
    await _localStorage.setString('${_getUserPrefix()}chat_id_user_$targetUserId', chatId.toString());
  }

  @override
  int? getChatId(int targetUserId) {
    final str = _localStorage.getString('${_getUserPrefix()}chat_id_user_$targetUserId');
    if (str != null && str.isNotEmpty) {
      return int.tryParse(str);
    }
    return null;
  }

  @override
  Future<void> saveMessages(int chatId, List<MessageModel> messages) async {
    final jsonList = messages.map((m) => m.toJson()).toList();
    await _localStorage.setString('${_getUserPrefix()}chat_messages_$chatId', jsonEncode(jsonList));
  }

  @override
  List<MessageModel> getCachedMessages(int chatId) {
    final jsonString = _localStorage.getString('${_getUserPrefix()}chat_messages_$chatId');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> saveChatUserProfile(int chatId, Map<String, dynamic> userProfile) async {
    await _localStorage.setString('${_getUserPrefix()}chat_user_profile_$chatId', jsonEncode(userProfile));
  }

  @override
  Map<String, dynamic>? getChatUserProfile(int chatId) {
    final jsonString = _localStorage.getString('${_getUserPrefix()}chat_user_profile_$chatId');
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }
}

