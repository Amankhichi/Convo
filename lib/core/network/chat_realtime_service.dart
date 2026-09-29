import 'dart:async';
import 'package:convo/core/network/stomp_service.dart';
import 'package:convo/features/chats/data/datasources/chat_local_datasource.dart';
import 'package:convo/features/chats/data/models/message_model.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';

class ChatRealtimeService {
  final StompService _stompService;
  final ChatLocalDataSource _chatLocalDataSource;

  final StreamController<MessageEntity> _newMessageController =
      StreamController<MessageEntity>.broadcast();

  final StreamController<Map<String, dynamic>> _statusEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<Map<String, dynamic>> _presenceEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageEntity> get newMessageStream => _newMessageController.stream;
  Stream<Map<String, dynamic>> get statusEventStream =>
      _statusEventController.stream;
  Stream<Map<String, dynamic>> get presenceEventStream =>
      _presenceEventController.stream;

  StreamSubscription? _wsSubscription;

  ChatRealtimeService(this._stompService, this._chatLocalDataSource) {
    _initStompListener();
  }

  void _initStompListener() {
    _stompService.connect();
    _wsSubscription = _stompService.messageEvents.listen((data) {
      _handleIncomingEvent(data);
    });
  }

  void subscribeToChat(int chatId) {
    _stompService.subscribeToChat(chatId);
  }

  void unsubscribeFromChat(int chatId) {
    _stompService.unsubscribeFromChat(chatId);
  }

  void sendDeliveryReceipt(int chatId, int messageId) {
    _stompService.notifyMessageDelivered(chatId, messageId);
  }

  void sendReadReceipt(int chatId, int messageId) {
    _stompService.notifyMessageSeen(chatId, messageId);
  }

  void notifyMessageSeen(int chatId, int messageId) {
    _stompService.notifyMessageSeen(chatId, messageId);
  }

  void sendTypingNotification(int chatId, bool isTyping) {
    _stompService.sendTypingNotification(chatId, isTyping);
  }

  void _handleIncomingEvent(Map<String, dynamic> json) {
    try {
      final eventType = json['type']?.toString() ?? 'message:new';

      if (eventType == 'presence' ||
          json.containsKey('presence') ||
          (json.containsKey('userId') &&
              (json.containsKey('status') || json.containsKey('online')))) {
        _presenceEventController.add(json);
        return;
      }

      if (eventType == 'message:seen' ||
          eventType == 'message:delivered' ||
          eventType == 'message:status' ||
          json.containsKey('seenAt') ||
          json.containsKey('deliveredAt')) {
        _statusEventController.add(json);
        return;
      }

      Map<String, dynamic> msgJson = json;
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        msgJson = json['data'] as Map<String, dynamic>;
      }

      if (msgJson.containsKey('chatId') &&
          (msgJson.containsKey('content') || msgJson.containsKey('message'))) {
        final messageModel = MessageModel.fromJson(msgJson);

        // Update local storage cache automatically
        final cached = _chatLocalDataSource.getCachedMessages(
          messageModel.chatId,
        );
        final existingIndex = cached.indexWhere((m) => m.id == messageModel.id);

        List<MessageModel> updatedList;
        if (existingIndex != -1) {
          updatedList = List.from(cached);
          updatedList[existingIndex] = messageModel;
        } else {
          updatedList = [...cached, messageModel];
        }

        _chatLocalDataSource.saveMessages(messageModel.chatId, updatedList);

        // Broadcast new message event to UI
        _newMessageController.add(messageModel);
      }
    } catch (_) {}
  }

  void dispose() {
    _wsSubscription?.cancel();
    _newMessageController.close();
    _statusEventController.close();
    _presenceEventController.close();
  }
}
