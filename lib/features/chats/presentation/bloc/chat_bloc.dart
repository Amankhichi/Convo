import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/core/network/chat_realtime_service.dart';
import 'package:convo/core/utils/logger.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/domain/repositories/chat_repository.dart';
import 'package:convo/features/chats/presentation/bloc/chat_event.dart';
import 'package:convo/features/chats/presentation/bloc/chat_state.dart';
import 'package:convo/injection/dependency_injection.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final ChatRealtimeService _realtimeService;

  StreamSubscription? _messageSub;
  StreamSubscription? _statusSub;
  Timer? _pollTimer;
  int _activeChatId = 0;

  ChatBloc({
    required ChatRepository chatRepository,
    required ChatRealtimeService realtimeService,
  })  : _chatRepository = chatRepository,
        _realtimeService = realtimeService,
        super(ChatInitial()) {
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<SendMediaMessageEvent>(_onSendMediaMessage);
    on<RetrySendMessageEvent>(_onRetrySendMessage);
    on<MarkMessagesSeenEvent>(_onMarkMessagesSeen);
    on<RealtimeMessageReceivedEvent>(_onRealtimeMessageReceived);
    on<RealtimeStatusUpdatedEvent>(_onRealtimeStatusUpdated);
    on<EditMessageEvent>(_onEditMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);

    _listenRealtimeEvents();
  }

  void _listenRealtimeEvents() {
    _messageSub = _realtimeService.newMessageStream.listen((msg) {
      if (msg.chatId == _activeChatId) {
        add(RealtimeMessageReceivedEvent(msg));
      }
    });

    _statusSub = _realtimeService.statusEventStream.listen((data) {
      add(RealtimeStatusUpdatedEvent(data));
    });
  }

  List<MessageEntity> _sortNewestFirst(List<MessageEntity> list) {
    final copy = List<MessageEntity>.from(list);
    copy.sort((a, b) {
      try {
        final dtA = DateTime.parse(a.createdAt);
        final dtB = DateTime.parse(b.createdAt);
        return dtB.compareTo(dtA); // Newest at index 0
      } catch (_) {
        return 0;
      }
    });
    return copy;
  }

  void _startPolling(int chatId) {
    _pollTimer?.cancel();
    if (chatId <= 0) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_activeChatId != chatId) return;
      try {
        final remote = await _chatRepository.fetchMessages(chatId);
        if (state is ChatLoaded) {
          final currentList = (state as ChatLoaded).messages;
          for (final msg in remote) {
            final idx = currentList.indexWhere((m) =>
                (msg.clientMessageId != null && m.clientMessageId == msg.clientMessageId) ||
                (msg.id != 0 && m.id == msg.id));
            if (idx == -1) {
              add(RealtimeMessageReceivedEvent(msg));
            }
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_activeChatId != 0 && _activeChatId != event.chatId) {
      _realtimeService.unsubscribeFromChat(_activeChatId);
    }
    _activeChatId = event.chatId;
    _realtimeService.subscribeToChat(event.chatId);
    _startPolling(event.chatId);

    final cached = _chatRepository.getCachedMessages(event.chatId);
    final sortedCached = _sortNewestFirst(cached);
    if (sortedCached.isNotEmpty) {
      emit(ChatLoaded(sortedCached, reason: ChatLoadedReason.initialFetch));
    } else {
      emit(ChatLoading());
    }

    try {
      final messages = await _chatRepository.fetchMessages(event.chatId);
      final sortedMessages = _sortNewestFirst(messages);
      emit(ChatLoaded(sortedMessages, reason: ChatLoadedReason.initialFetch));
      add(MarkMessagesSeenEvent(event.chatId));
    } catch (e) {
      if (sortedCached.isNotEmpty) {
        emit(ChatLoaded(sortedCached, reason: ChatLoadedReason.initialFetch));
      } else {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    List<MessageEntity> currentMessages = [];
    if (state is ChatLoaded) {
      currentMessages = List.from((state as ChatLoaded).messages);
    }

    final clientMsgId = event.clientMessageId ??
        "client_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}";

    AppLogger.d("[SEND] clientMessageId=$clientMsgId content=${event.content}");

    // 1. Optimistic Local UI update with status = SENDING (⏳)
    final tempPendingMessage = MessageEntity(
      id: 0,
      clientMessageId: clientMsgId,
      chatId: event.chatId,
      senderId: 0, // Current User
      receiverId: event.receiverId,
      type: event.type,
      content: event.content,
      mediaUrl: event.mediaUrl,
      status: "SENDING",
      createdAt: DateTime.now().toIso8601String(),
      seen: false,
    );

    // Insert at index 0 (newest first)
    final optimisticList = [tempPendingMessage, ...currentMessages];
    emit(ChatLoaded(optimisticList, reason: ChatLoadedReason.messageSent));

    try {
      // 2. Send message to backend via POST /api/messages
      final sentMessage = await _chatRepository.sendMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        content: event.content,
        type: event.type,
        mediaUrl: event.mediaUrl,
        replyToId: event.replyToId,
      );

      AppLogger.d("[SENT] messageId=${sentMessage.id} clientMessageId=$clientMsgId");

      // 3. Update status from SENDING to SENT (✓) matching by clientMessageId or temp id
      final index = optimisticList.indexWhere(
        (m) => (clientMsgId.isNotEmpty && m.clientMessageId == clientMsgId) || (m.id != 0 && m.id == tempPendingMessage.id),
      );

      if (index != -1) {
        final existing = optimisticList[index];
        final targetStatus = existing.canTransitionTo(MessageStatus.sent)
            ? 'SENT'
            : existing.status;

        optimisticList[index] = MessageEntity(
          id: sentMessage.id,
          clientMessageId: clientMsgId,
          chatId: sentMessage.chatId,
          senderId: sentMessage.senderId,
          receiverId: sentMessage.receiverId,
          type: sentMessage.type,
          content: sentMessage.content,
          mediaUrl: sentMessage.mediaUrl,
          status: targetStatus,
          createdAt: sentMessage.createdAt,
          seen: existing.seen || sentMessage.seen || targetStatus == 'SEEN',
        );
      } else {
        optimisticList.insert(0, sentMessage);
      }

      final sortedList = _sortNewestFirst(optimisticList);
      emit(ChatLoaded(sortedList, reason: ChatLoadedReason.messageSent));
      _chatRepository.saveCachedMessages(event.chatId, sortedList);
    } catch (e) {
      AppLogger.e("Sending message failed: $e");
      final index = optimisticList.indexWhere(
        (m) => m.clientMessageId == clientMsgId,
      );
      if (index != -1) {
        optimisticList[index] = MessageEntity(
          id: 0,
          clientMessageId: clientMsgId,
          chatId: event.chatId,
          senderId: 0,
          receiverId: event.receiverId,
          type: "TEXT",
          content: event.content,
          status: "FAILED",
          createdAt: tempPendingMessage.createdAt,
          seen: false,
        );
        final failedList = List<MessageEntity>.from(optimisticList);
        emit(ChatLoaded(failedList, reason: ChatLoadedReason.statusUpdated));
        _chatRepository.saveCachedMessages(event.chatId, failedList);
      }
    }
  }

  Future<void> _onSendMediaMessage(
    SendMediaMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    List<MessageEntity> currentMessages = [];
    if (state is ChatLoaded) {
      currentMessages = List.from((state as ChatLoaded).messages);
    }

    final clientMsgId = event.clientMessageId ??
        "client_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}";

    AppLogger.d("[MEDIA] Selected ${event.type} clientMessageId=$clientMsgId path=${event.filePath}");

    // 1. Optimistic Local UI update with status = UPLOADING
    final tempUploadingMessage = MessageEntity(
      id: 0,
      clientMessageId: clientMsgId,
      chatId: event.chatId,
      senderId: 0, // Current User
      receiverId: event.receiverId,
      type: event.type,
      content: event.content,
      mediaUrl: event.filePath,
      status: "UPLOADING",
      createdAt: DateTime.now().toIso8601String(),
      seen: false,
      replyToId: event.replyToId,
    );

    // Replace if existing clientMsgId (retry case) or insert at top
    final existingIdx = currentMessages.indexWhere((m) => m.clientMessageId == clientMsgId);
    List<MessageEntity> optimisticList;
    if (existingIdx != -1) {
      currentMessages[existingIdx] = tempUploadingMessage;
      optimisticList = List.from(currentMessages);
    } else {
      optimisticList = [tempUploadingMessage, ...currentMessages];
    }
    emit(ChatLoaded(optimisticList, reason: ChatLoadedReason.messageSent));

    try {
      AppLogger.d("[MEDIA] Upload started: ${event.filePath}");
      final file = File(event.filePath);
      final bytes = await file.readAsBytes();
      final filename = event.filePath.split('/').last.split('\\').last;

      final res = await sl<ApiClient>().postMultipart(
        ApiConfig.mediaUpload,
        queryParameters: {},
        fileBytes: bytes,
        fileFieldName: "file",
        filename: filename.isNotEmpty ? filename : "media.file",
      );

      String uploadedUrl = "";
      if (res is Map<String, dynamic> && res["success"] == true) {
        uploadedUrl = res["data"]?["mediaUrl"]?.toString() ??
            res["data"]?["fileUrl"]?.toString() ??
            res["data"]?["url"]?.toString() ??
            "";
      }
      if (uploadedUrl.isEmpty && res is Map<String, dynamic>) {
        uploadedUrl = res["mediaUrl"]?.toString() ?? res["fileUrl"]?.toString() ?? "";
      }

      if (uploadedUrl.isEmpty) {
        throw Exception("Invalid response structure from media upload API");
      }

      AppLogger.d("[MEDIA] Upload success: uploadedUrl=$uploadedUrl");

      // 2. Transition status from UPLOADING to SENDING
      final sendingIdx = optimisticList.indexWhere((m) => m.clientMessageId == clientMsgId);
      if (sendingIdx != -1) {
        optimisticList[sendingIdx] = MessageEntity(
          id: 0,
          clientMessageId: clientMsgId,
          chatId: event.chatId,
          senderId: 0,
          receiverId: event.receiverId,
          type: event.type,
          content: event.content,
          mediaUrl: uploadedUrl,
          status: "SENDING",
          createdAt: tempUploadingMessage.createdAt,
          seen: false,
          replyToId: event.replyToId,
        );
        emit(ChatLoaded(List.from(optimisticList), reason: ChatLoadedReason.messageSent));
      }

      AppLogger.d("[CHAT] ${event.type} message send started");

      // 3. Send message to backend via POST /api/messages
      final sentMessage = await _chatRepository.sendMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        content: event.content,
        type: event.type,
        mediaUrl: uploadedUrl,
        replyToId: event.replyToId,
      );

      AppLogger.d("[CHAT] ${event.type} message sent: messageId=${sentMessage.id}");

      // 4. Update status from SENDING to SENT (✓)
      final sentIdx = optimisticList.indexWhere((m) => m.clientMessageId == clientMsgId);
      if (sentIdx != -1) {
        optimisticList[sentIdx] = MessageEntity(
          id: sentMessage.id,
          clientMessageId: clientMsgId,
          chatId: sentMessage.chatId,
          senderId: sentMessage.senderId,
          receiverId: sentMessage.receiverId,
          type: sentMessage.type,
          content: sentMessage.content,
          mediaUrl: sentMessage.mediaUrl ?? uploadedUrl,
          status: "SENT",
          createdAt: sentMessage.createdAt,
          seen: sentMessage.seen,
          replyToId: sentMessage.replyToId,
          replyToContent: sentMessage.replyToContent,
        );
      } else {
        optimisticList.insert(0, sentMessage);
      }

      final sortedList = _sortNewestFirst(optimisticList);
      emit(ChatLoaded(sortedList, reason: ChatLoadedReason.messageSent));
      _chatRepository.saveCachedMessages(event.chatId, sortedList);
    } catch (e) {
      AppLogger.e("Media upload or send failed: $e");
      final failIdx = optimisticList.indexWhere((m) => m.clientMessageId == clientMsgId);
      if (failIdx != -1) {
        optimisticList[failIdx] = MessageEntity(
          id: 0,
          clientMessageId: clientMsgId,
          chatId: event.chatId,
          senderId: 0,
          receiverId: event.receiverId,
          type: event.type,
          content: event.content,
          mediaUrl: event.filePath,
          status: "FAILED",
          createdAt: tempUploadingMessage.createdAt,
          seen: false,
          replyToId: event.replyToId,
        );
        final failedList = List<MessageEntity>.from(optimisticList);
        emit(ChatLoaded(failedList, reason: ChatLoadedReason.statusUpdated));
        _chatRepository.saveCachedMessages(event.chatId, failedList);
      }
    }
  }

  Future<void> _onRetrySendMessage(
    RetrySendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentList = List<MessageEntity>.from((state as ChatLoaded).messages);

    final msg = event.message;

    // If media upload failed, retry via SendMediaMessageEvent
    if (msg.type != "TEXT" && msg.mediaUrl != null && !msg.mediaUrl!.startsWith("http")) {
      add(
        SendMediaMessageEvent(
          chatId: msg.chatId,
          receiverId: msg.receiverId ?? 0,
          filePath: msg.mediaUrl!,
          type: msg.type,
          content: msg.content,
          clientMessageId: msg.clientMessageId,
          replyToId: msg.replyToId,
        ),
      );
      return;
    }

    final index = currentList.indexWhere(
      (m) => (msg.clientMessageId != null && m.clientMessageId == msg.clientMessageId) || (msg.id != 0 && m.id == msg.id),
    );

    if (index == -1) return;

    currentList[index] = MessageEntity(
      id: msg.id,
      clientMessageId: msg.clientMessageId,
      chatId: msg.chatId,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      type: msg.type,
      content: msg.content,
      mediaUrl: msg.mediaUrl,
      status: "SENDING",
      createdAt: msg.createdAt,
      seen: false,
    );
    emit(ChatLoaded(List.from(currentList), reason: ChatLoadedReason.messageSent));

    AppLogger.d("[SEND] Retrying message clientMessageId=${msg.clientMessageId}");

    try {
      final sentMessage = await _chatRepository.sendMessage(
        chatId: msg.chatId,
        receiverId: msg.receiverId ?? 0,
        content: msg.content,
      );

      AppLogger.d("[SENT] Retry succeeded for messageId=${sentMessage.id}");

      currentList[index] = MessageEntity(
        id: sentMessage.id,
        clientMessageId: msg.clientMessageId,
        chatId: sentMessage.chatId,
        senderId: sentMessage.senderId,
        receiverId: sentMessage.receiverId,
        type: sentMessage.type,
        content: sentMessage.content,
        mediaUrl: sentMessage.mediaUrl,
        status: "SENT",
        createdAt: sentMessage.createdAt,
        seen: false,
      );
      emit(ChatLoaded(_sortNewestFirst(currentList), reason: ChatLoadedReason.messageSent));
    } catch (e) {
      AppLogger.e("Retry failed: $e");
      currentList[index] = MessageEntity(
        id: msg.id,
        clientMessageId: msg.clientMessageId,
        chatId: msg.chatId,
        senderId: msg.senderId,
        receiverId: msg.receiverId,
        type: msg.type,
        content: msg.content,
        mediaUrl: msg.mediaUrl,
        status: "FAILED",
        createdAt: msg.createdAt,
        seen: false,
      );
      emit(ChatLoaded(List.from(currentList), reason: ChatLoadedReason.statusUpdated));
    }
  }

  void _onMarkMessagesSeen(
    MarkMessagesSeenEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final messages = (state as ChatLoaded).messages;
      for (final msg in messages) {
        if (msg.senderId != 0 && !msg.seen && msg.id > 0) {
          _realtimeService.sendReadReceipt(event.chatId, msg.id);
        }
      }
    }
  }

  void _onRealtimeMessageReceived(
    RealtimeMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentList = List<MessageEntity>.from((state as ChatLoaded).messages);
      final newMsg = event.message;

      final index = currentList.indexWhere((m) =>
          (newMsg.clientMessageId != null && m.clientMessageId == newMsg.clientMessageId) ||
          (newMsg.id != 0 && m.id == newMsg.id));

      if (index != -1) {
        final existing = currentList[index];
        final targetStatus = existing.canTransitionTo(newMsg.messageStatus)
            ? newMsg.status
            : existing.status;

        currentList[index] = MessageEntity(
          id: newMsg.id != 0 ? newMsg.id : existing.id,
          clientMessageId: newMsg.clientMessageId ?? existing.clientMessageId,
          chatId: newMsg.chatId,
          senderId: newMsg.senderId,
          receiverId: newMsg.receiverId ?? existing.receiverId,
          type: newMsg.type,
          content: newMsg.content,
          mediaUrl: newMsg.mediaUrl ?? existing.mediaUrl,
          status: targetStatus,
          createdAt: newMsg.createdAt,
          seen: existing.seen || newMsg.seen || targetStatus == 'SEEN',
        );
      } else {
        currentList.insert(0, newMsg); // Insert at index 0 (newest first)
      }

      final sortedList = _sortNewestFirst(currentList);
      emit(ChatLoaded(sortedList, reason: ChatLoadedReason.realtimeReceived));
      _chatRepository.saveCachedMessages(newMsg.chatId, sortedList);

      if (newMsg.senderId != 0 && newMsg.id > 0) {
        // Send delivery ACK to backend so sender gets ✓✓
        _realtimeService.sendDeliveryReceipt(newMsg.chatId, newMsg.id);

        // If recipient is currently viewing this chat, send read ACK so sender gets Blue ✓✓
        if (newMsg.chatId == _activeChatId) {
          _realtimeService.sendReadReceipt(_activeChatId, newMsg.id);
        }
      }
    }
  }

  void _onRealtimeStatusUpdated(
    RealtimeStatusUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentList = List<MessageEntity>.from((state as ChatLoaded).messages);
      final data = event.statusData;
      final msgId = data['messageId'] ?? data['id'];
      final clientMsgId = data['clientMessageId']?.toString();
      final eventType = data['type']?.toString().toUpperCase() ?? '';
      String statusStr = data['status']?.toString().toUpperCase() ?? '';

      if (statusStr.isEmpty) {
        if (eventType.contains('SENT')) statusStr = 'SENT';
        if (eventType.contains('DELIVERED')) statusStr = 'DELIVERED';
        if (eventType.contains('SEEN')) statusStr = 'SEEN';
      }

      MessageStatus? newStatus;
      switch (statusStr) {
        case 'SENDING':
        case 'PENDING':
          newStatus = MessageStatus.sending;
          break;
        case 'SENT':
          newStatus = MessageStatus.sent;
          break;
        case 'DELIVERED':
          newStatus = MessageStatus.delivered;
          break;
        case 'SEEN':
          newStatus = MessageStatus.seen;
          break;
        case 'FAILED':
          newStatus = MessageStatus.failed;
          break;
        default:
          newStatus = null;
      }

      if (newStatus == null) return;

      bool updated = false;
      for (int i = 0; i < currentList.length; i++) {
        final item = currentList[i];
        final isMatch = (clientMsgId != null && clientMsgId.isNotEmpty && item.clientMessageId == clientMsgId) ||
            (msgId != null && item.id != 0 && item.id.toString() == msgId.toString());

        if (isMatch) {
          if (item.canTransitionTo(newStatus)) {
            if (newStatus == MessageStatus.delivered) {
              AppLogger.d("[DELIVERED] messageId=$msgId clientMessageId=$clientMsgId");
            } else if (newStatus == MessageStatus.seen) {
              AppLogger.d("[SEEN] messageId=$msgId clientMessageId=$clientMsgId");
            }

            currentList[i] = MessageEntity(
              id: item.id != 0 ? item.id : (msgId is int ? msgId : int.tryParse(msgId?.toString() ?? '0') ?? 0),
              clientMessageId: item.clientMessageId ?? clientMsgId,
              chatId: item.chatId,
              senderId: item.senderId,
              receiverId: item.receiverId,
              type: item.type,
              content: item.content,
              mediaUrl: item.mediaUrl,
              status: newStatus.toStatusString(),
              createdAt: item.createdAt,
              seen: item.seen || newStatus == MessageStatus.seen,
            );
            updated = true;
          }
        }
      }

      if (updated) {
        emit(ChatLoaded(currentList, reason: ChatLoadedReason.statusUpdated));
        if (_activeChatId > 0) {
          _chatRepository.saveCachedMessages(_activeChatId, currentList);
        }
      }
    }
  }

  Future<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentList = List<MessageEntity>.from((state as ChatLoaded).messages);
    final idx = currentList.indexWhere((m) => m.id == event.messageId);
    if (idx == -1) return;

    try {
      final editedMsg = await _chatRepository.editMessage(event.messageId, event.newContent);
      currentList[idx] = editedMsg;
      final sorted = _sortNewestFirst(currentList);
      emit(ChatLoaded(sorted, reason: ChatLoadedReason.statusUpdated));
      if (_activeChatId > 0) {
        _chatRepository.saveCachedMessages(_activeChatId, sorted);
      }
    } catch (e) {
      AppLogger.e("Edit message failed: $e");
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentList = List<MessageEntity>.from((state as ChatLoaded).messages);
    final idx = currentList.indexWhere((m) => m.id == event.messageId);
    if (idx == -1) return;

    currentList.removeAt(idx);
    final sorted = _sortNewestFirst(currentList);
    emit(ChatLoaded(sorted, reason: ChatLoadedReason.statusUpdated));
    if (_activeChatId > 0) {
      _chatRepository.saveCachedMessages(_activeChatId, sorted);
    }

    try {
      await _chatRepository.deleteMessage(event.messageId);
    } catch (e) {
      AppLogger.e("Delete message failed: $e");
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    if (_activeChatId != 0) {
      _realtimeService.unsubscribeFromChat(_activeChatId);
    }
    _messageSub?.cancel();
    _statusSub?.cancel();
    return super.close();
  }
}

