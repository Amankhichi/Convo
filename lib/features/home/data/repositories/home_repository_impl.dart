import 'package:convo/app/config/api_config.dart';
import 'package:convo/features/chats/data/datasources/chat_local_datasource.dart';
import 'package:convo/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:convo/features/home/data/datasources/home_local_datasource.dart';
import 'package:convo/features/home/data/datasources/home_remote_datasource.dart';
import 'package:convo/features/home/data/models/chat_summary_model.dart';
import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';
import 'package:convo/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;
  final ContactsLocalDataSource? _contactsLocalDataSource;
  final ChatLocalDataSource? _chatLocalDataSource;

  HomeRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, [
    this._contactsLocalDataSource,
    this._chatLocalDataSource,
  ]);

  List<ChatSummaryModel> _enrichChats(List<ChatSummaryModel> rawChats) {
    final contacts = _contactsLocalDataSource?.getCachedContacts() ?? [];

    return rawChats.map((chat) {
      String name = chat.targetUserName;
      String image = chat.targetUserImage;
      String about = chat.targetUserAbout;
      String phone = chat.targetUserPhone;
      String lastContent = chat.lastMessageContent;
      String lastTime = chat.lastMessageTime;

      // 1. Check local contacts
      final matchingContact = contacts.firstWhere(
        (c) =>
            (chat.targetUserId > 0 && c.id == chat.targetUserId) ||
            (c.phoneNumber.isNotEmpty && c.phoneNumber == chat.targetUserPhone),
        orElse: () => contacts.firstWhere(
          (c) => c.name.isNotEmpty && c.name == chat.targetUserName,
          orElse: () => contacts.first,
        ),
      );

      if (contacts.isNotEmpty &&
          matchingContact.name.isNotEmpty &&
          (matchingContact.id == chat.targetUserId ||
              matchingContact.phoneNumber == chat.targetUserPhone)) {
        if (name == 'ConVo User' || name.isEmpty) {
          name = matchingContact.name;
        }
        if (image.isEmpty && matchingContact.profileImage.isNotEmpty) {
          image = ApiConfig.sanitizeUrl(matchingContact.profileImage);
        }
        if (phone.isEmpty && matchingContact.phoneNumber.isNotEmpty) {
          phone = matchingContact.phoneNumber;
        }
        if (about.isEmpty && matchingContact.about.isNotEmpty) {
          about = matchingContact.about;
        }
      }

      // 2. Check local user profile
      final localChatDs = _chatLocalDataSource;
      if (chat.chatId > 0 && localChatDs != null) {
        final profile = localChatDs.getChatUserProfile(chat.chatId);
        if (profile != null) {
          if (name == 'ConVo User' || name.isEmpty) {
            name = profile['name']?.toString() ?? name;
          }
          if (image.isEmpty) {
            image = ApiConfig.sanitizeUrl(profile['profileImage']?.toString() ?? '');
          }
          if (about.isEmpty) {
            about = profile['about']?.toString() ?? about;
          }
          if (phone.isEmpty) {
            phone = profile['phone']?.toString() ?? phone;
          }
        }

        // 3. Check local message cache for chat preview
        if (lastContent.isEmpty || lastContent == "Tap to chat") {
          final cachedMsgs = localChatDs.getCachedMessages(chat.chatId);
          if (cachedMsgs.isNotEmpty) {
            final latestMsg = cachedMsgs.first; // newest message
            String content = latestMsg.content;
            if (latestMsg.type == "IMAGE") {
              content = "📷 Photo";
            } else if (latestMsg.type == "VIDEO") {
              content = "🎥 Video";
            } else if (latestMsg.type == "AUDIO") {
              content = "🎵 Voice message";
            } else if (latestMsg.type == "FILE") {
              content = "📁 File";
            }

            final isMe = latestMsg.senderId != chat.targetUserId;
            if (isMe && content.isNotEmpty && !content.startsWith("You: ")) {
              content = "You: $content";
            }

            if (content.isNotEmpty) {
              lastContent = content;
            }
            if (lastTime.isEmpty && latestMsg.createdAt.isNotEmpty) {
              lastTime = latestMsg.createdAt;
            }
          }
        }
      }

      return ChatSummaryModel(
        chatId: chat.chatId,
        chatType: chat.chatType,
        targetUserId: chat.targetUserId,
        targetUserName: name,
        targetUserImage: image,
        targetUserAbout: about,
        targetUserPhone: phone,
        lastMessageContent: lastContent,
        lastMessageTime: lastTime,
        unreadCount: chat.unreadCount,
        online: chat.online,
      );
    }).toList();
  }

  @override
  Future<List<ChatSummaryEntity>> fetchChats() async {
    try {
      final remoteChats = await _remoteDataSource.fetchChats();
      final enrichedRemote = _enrichChats(remoteChats);
      await _localDataSource.saveChats(enrichedRemote);
      return enrichedRemote;
    } catch (e) {
      final cached = getCachedChats();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  List<ChatSummaryEntity> getCachedChats() {
    final rawCached = _localDataSource.getCachedChats();
    final enrichedCached = _enrichChats(rawCached);

    if (enrichedCached.isNotEmpty) {
      return enrichedCached;
    }

    // Fallback: Construct chats from local contacts if no cached chats exist yet
    final contacts = _contactsLocalDataSource?.getCachedContacts() ?? [];
    if (contacts.isNotEmpty) {
      final fallbackList = <ChatSummaryModel>[];
      final chatDs = _chatLocalDataSource;

      for (final contact in contacts) {
        if (contact.id <= 0) continue;
        final chatId = chatDs?.getChatId(contact.id) ?? 0;
        String lastContent = "";
        String lastTime = "";

        if (chatId > 0 && chatDs != null) {
          final msgs = chatDs.getCachedMessages(chatId);
          if (msgs.isNotEmpty) {
            final latest = msgs.first;
            lastContent = latest.content;
            if (latest.type == "IMAGE") lastContent = "📷 Photo";
            if (latest.type == "VIDEO") lastContent = "🎥 Video";
            if (latest.type == "AUDIO") lastContent = "🎵 Voice message";
            if (latest.type == "FILE") lastContent = "📁 File";

            if (latest.senderId != contact.id && lastContent.isNotEmpty) {
              lastContent = "You: $lastContent";
            }
            lastTime = latest.createdAt;
          }
        }

        fallbackList.add(ChatSummaryModel(
          chatId: chatId,
          chatType: "DIRECT",
          targetUserId: contact.id,
          targetUserName: contact.name,
          targetUserImage: ApiConfig.sanitizeUrl(contact.profileImage),
          targetUserAbout: contact.about,
          targetUserPhone: contact.phoneNumber,
          lastMessageContent: lastContent,
          lastMessageTime: lastTime,
          unreadCount: 0,
          online: false,
        ));
      }

      if (fallbackList.isNotEmpty) {
        _localDataSource.saveChats(fallbackList);
        return fallbackList;
      }
    }

    return [];
  }
}
