import 'dart:async';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/network/chat_realtime_service.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/features/chats/data/datasources/chat_local_datasource.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:convo/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:convo/features/chats/presentation/bloc/chat_event.dart';
import 'package:convo/features/chats/presentation/bloc/chat_state.dart';
import 'package:convo/features/chats/presentation/pages/image_preview_page.dart';
import 'package:convo/features/chats/presentation/pages/video_preview_page.dart';
import 'package:convo/features/chats/presentation/widgets/attachment_bottom_sheet.dart';
import 'package:convo/features/chats/presentation/widgets/chat_app_bar.dart';
import 'package:convo/features/chats/presentation/widgets/chat_input_bar.dart';
import 'package:convo/features/chats/presentation/widgets/chat_message_list.dart';
import 'package:convo/features/chats/presentation/widgets/chat_search_widget.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final int targetUserId;
  final String contactName;
  final String contactPhone;
  final String contactImage;
  final String contactAbout;
  final bool isOnline;

  const ChatPage({
    super.key,
    this.chatId = 0,
    this.targetUserId = 0,
    this.contactName = "ConVo User",
    this.contactPhone = "",
    this.contactImage = "",
    this.contactAbout = "",
    this.isOnline = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  int _activeChatId = 0;
  String _displayName = "";
  String _displayImage = "";
  String _displayAbout = "";
  bool _displayOnline = false;
  String? _displayLastSeen;
  StreamSubscription? _presenceSubscription;

  bool _isRecordingAudio = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _hasUnreadBelow = false;

  MessageEntity? _replyingMessage;
  MessageEntity? _editingMessage;

  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _highlightedClientMsgId;
  int? _highlightedMsgId;
  Timer? _highlightTimer;

  // Selection mode
  bool _isSelectionMode = false;
  final Set<int> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _displayName = widget.contactName;
    _displayImage = widget.contactImage;
    _displayAbout = widget.contactAbout;
    _displayOnline = widget.isOnline;

    _scrollController.addListener(_onScroll);
    _restoreOrSaveLocalProfile();

    _presenceSubscription = sl<ChatRealtimeService>()
        .presenceEventStream
        .listen(_handlePresenceEvent);
  }

  void _handlePresenceEvent(Map<String, dynamic> event) {
    final eventUserId = event['userId'] is int
        ? event['userId']
        : int.tryParse(event['userId']?.toString() ?? '0');

    if (eventUserId == null ||
        eventUserId == 0 ||
        eventUserId != widget.targetUserId) {
      return;
    }

    final isOnline = event['online'] == true ||
        event['status']?.toString().toUpperCase() == 'ONLINE';
    final lastSeen = event['lastSeen']?.toString();

    if (mounted) {
      setState(() {
        _displayOnline = isOnline;
        if (lastSeen != null && lastSeen.isNotEmpty) {
          _displayLastSeen = lastSeen;
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients && _isNearBottom && _hasUnreadBelow) {
      setState(() {
        _hasUnreadBelow = false;
      });
    }
  }

  void _restoreOrSaveLocalProfile() {
    if (_activeChatId <= 0) return;

    final cachedProfile = sl<ChatLocalDataSource>().getChatUserProfile(_activeChatId);
    if (cachedProfile != null) {
      setState(() {
        if (_displayName.isEmpty || _displayName == "ConVo User") {
          _displayName = cachedProfile['name']?.toString() ?? widget.contactName;
        }
        if (_displayImage.isEmpty) {
          _displayImage = cachedProfile['profileImage']?.toString() ?? widget.contactImage;
        }
        if (_displayAbout.isEmpty) {
          _displayAbout = cachedProfile['about']?.toString() ?? widget.contactAbout;
        }
        _displayOnline = cachedProfile['online'] == true;
        _displayLastSeen = cachedProfile['lastSeen']?.toString();
      });
    } else {
      sl<ChatLocalDataSource>().saveChatUserProfile(_activeChatId, {
        'id': widget.targetUserId,
        'name': widget.contactName,
        'phone': widget.contactPhone,
        'profileImage': widget.contactImage,
        'about': widget.contactAbout,
        'online': widget.isOnline,
        'lastSeen': null,
      });
    }
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    _recordingTimer?.cancel();
    _highlightTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.pixels <= 150;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getPresenceSubtitle() {
    if (_displayOnline) return "Online";
    if (_displayLastSeen != null && _displayLastSeen!.isNotEmpty) {
      try {
        final dt = DateTime.parse(_displayLastSeen!).toLocal();
        final formattedTime = DateFormat('h:mm a').format(dt);
        final today = DateTime.now();
        if (dt.year == today.year &&
            dt.month == today.month &&
            dt.day == today.day) {
          return "Last seen today at $formattedTime";
        }
        return "Last seen ${DateFormat('MMM d').format(dt)} at $formattedTime";
      } catch (_) {}
    }
    return "Offline";
  }

  void _openUserProfile() {
    Navigator.pushNamed(
      context,
      RouteNames.contactProfile,
      arguments: {
        'userId': widget.targetUserId,
        'name': _displayName,
        'phone': widget.contactPhone,
        'image': _displayImage,
        'about': _displayAbout,
        'isOnline': _displayOnline,
        'lastSeen': _displayLastSeen,
      },
    );
  }

  void _openAttachmentSheet(ChatBloc chatBloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachmentBottomSheet(
        onSelect: (type) async {
          switch (type) {
            case AttachmentType.galleryImage:
            case AttachmentType.cameraImage:
              final file = await _picker.pickImage(
                source: type == AttachmentType.cameraImage
                    ? ImageSource.camera
                    : ImageSource.gallery,
              );
              if (file != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImagePreviewPage(
                      imagePath: file.path,
                      chatId: _activeChatId,
                      targetUserId: widget.targetUserId,
                      chatBloc: chatBloc,
                    ),
                  ),
                );
              }
              break;
            case AttachmentType.galleryVideo:
            case AttachmentType.cameraVideo:
              final file = await _picker.pickVideo(
                source: type == AttachmentType.cameraVideo
                    ? ImageSource.camera
                    : ImageSource.gallery,
              );
              if (file != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPreviewPage(
                      videoPath: file.path,
                      chatId: _activeChatId,
                      targetUserId: widget.targetUserId,
                      chatBloc: chatBloc,
                    ),
                  ),
                );
              }
              break;
            case AttachmentType.audio:
              final file = await _picker.pickMedia();
              if (file != null && mounted) {
                _uploadAndSendMediaFile(
                  file.path,
                  chatBloc: chatBloc,
                  isAudio: true,
                );
              }
              break;
            case AttachmentType.document:
            case AttachmentType.location:
            case AttachmentType.contact:
              break;
          }
        },
      ),
    );
  }

  Future<void> _toggleAudioRecording(ChatBloc chatBloc) async {
    if (_isRecordingAudio) {
      _recordingTimer?.cancel();
      setState(() {
        _isRecordingAudio = false;
      });
      final path = await _audioRecorder.stop();
      if (path != null && path.isNotEmpty) {
        _uploadAndSendMediaFile(path, chatBloc: chatBloc, isAudio: true);
      }
      _recordingSeconds = 0;
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecordingAudio = true;
          _recordingSeconds = 0;
        });
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
          });
        });
      }
    }
  }

  Future<void> _cancelAudioRecording() async {
    _recordingTimer?.cancel();
    if (_isRecordingAudio) {
      await _audioRecorder.stop();
    }
    setState(() {
      _isRecordingAudio = false;
      _recordingSeconds = 0;
    });
  }

  void _uploadAndSendMediaFile(
    String filePath, {
    required ChatBloc chatBloc,
    bool isAudio = false,
  }) {
    chatBloc.add(
      SendMediaMessageEvent(
        chatId: _activeChatId,
        receiverId: widget.targetUserId,
        filePath: filePath,
        type: isAudio ? "AUDIO" : "FILE",
        content: isAudio ? "🎵 Voice Message" : "📁 File",
      ),
    );
  }

  void _sendMessage(String text, ChatBloc chatBloc) {
    if (_editingMessage != null) {
      chatBloc.add(EditMessageEvent(messageId: _editingMessage!.id, newContent: text));
      setState(() {
        _editingMessage = null;
      });
      return;
    }

    final clientMsgId =
        "local_${DateTime.now().millisecondsSinceEpoch}_${widget.targetUserId}";

    chatBloc.add(
      SendMessageEvent(
        chatId: _activeChatId,
        receiverId: widget.targetUserId,
        content: text,
        clientMessageId: clientMsgId,
        replyToId: _replyingMessage?.id,
      ),
    );

    setState(() {
      _replyingMessage = null;
    });
    _scrollToBottom();
  }

  void _navigateToSearchResult(
    MessageEntity targetMsg,
    List<MessageEntity> messages,
  ) {
    setState(() {
      _isSearching = false;
      _searchQuery = "";
      _searchController.clear();
      _highlightedClientMsgId = targetMsg.clientMessageId;
      _highlightedMsgId = targetMsg.id;
    });

    final targetIndex = messages.indexWhere(
      (m) =>
          (targetMsg.clientMessageId != null &&
              targetMsg.clientMessageId!.isNotEmpty &&
              m.clientMessageId == targetMsg.clientMessageId) ||
          (targetMsg.id != 0 && m.id == targetMsg.id),
    );

    if (targetIndex != -1) {
      const estimatedItemHeight = 76.0;
      final estimatedOffset = targetIndex * estimatedItemHeight;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          estimatedOffset.clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }

      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _highlightedClientMsgId = null;
            _highlightedMsgId = null;
          });
        }
      });
    }
  }

  bool _canEditSelectedMessage(List<MessageEntity> messages) {
    if (_selectedMessageIds.length != 1) return false;
    final selectedId = _selectedMessageIds.first;
    final msg = messages.firstWhere(
      (m) => m.id == selectedId,
      orElse: () => MessageEntity(
        id: 0,
        chatId: 0,
        senderId: 0,
        type: "TEXT",
        content: "",
        status: "SENT",
        createdAt: "",
        seen: false,
      ),
    );
    if (msg.id == 0) return false;
    final isMe = (msg.senderId != widget.targetUserId);
    return isMe && msg.type == "TEXT";
  }

  void _startEditingMessage(MessageEntity msg) {
    setState(() {
      _editingMessage = msg;
      _replyingMessage = null;
    });
  }

  void _deleteSelectedMessages(BuildContext blocContext) {
    final chatBloc = blocContext.read<ChatBloc>();
    final count = _selectedMessageIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete $count message(s)?"),
        content: const Text("Are you sure you want to delete these messages?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              for (final id in _selectedMessageIds) {
                chatBloc.add(DeleteMessageEvent(id));
              }
              setState(() {
                _isSelectionMode = false;
                _selectedMessageIds.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSelectionActions(
    BuildContext blocContext,
    List<MessageEntity> currentMessages,
  ) {
    return [
      if (_selectedMessageIds.length == 1 &&
          _canEditSelectedMessage(currentMessages))
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            final selectedId = _selectedMessageIds.first;
            final msg = currentMessages.firstWhere((m) => m.id == selectedId);
            _startEditingMessage(msg);
            setState(() {
              _isSelectionMode = false;
              _selectedMessageIds.clear();
            });
          },
        ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: () {
          _deleteSelectedMessages(blocContext);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<ChatBloc>(
      create: (_) => sl<ChatBloc>()
        ..add(
          FetchMessagesEvent(widget.chatId),
        ),
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            if (state.reason == ChatLoadedReason.realtimeReceived) {
              if (!_isNearBottom) {
                setState(() {
                  _hasUnreadBelow = true;
                });
              } else {
                _scrollToBottom();
              }
            }
          }
        },
        builder: (blocContext, state) {
          final currentMessages = state is ChatLoaded ? state.messages : <MessageEntity>[];
          final chatSearchWidget = ChatSearchWidget(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onQueryChanged: (q) {
              setState(() {
                _searchQuery = q;
              });
            },
            onCloseSearch: () {
              setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              });
            },
            currentMessages: currentMessages,
            targetUserId: widget.targetUserId,
            targetName: _displayName,
            onSelectResult: (msg, msgs) => _navigateToSearchResult(msg, msgs),
          );

          return AppScaffold(
            appBar: ChatAppBar(
              isSearching: _isSearching,
              isSelectionMode: _isSelectionMode,
              selectedCount: _selectedMessageIds.length,
              displayName: _displayName,
              displayImage: _displayImage,
              displayOnline: _displayOnline,
              presenceSubtitle: _getPresenceSubtitle(),
              searchAppBar: chatSearchWidget.buildSearchAppBar(context),
              selectionActions: _buildSelectionActions(blocContext, currentMessages),
              onBackPressed: () => Navigator.pop(context),
              onClearSelection: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedMessageIds.clear();
                });
              },
              onOpenProfile: _openUserProfile,
              onStartSearch: () {
                setState(() {
                  _isSearching = true;
                  _searchQuery = "";
                  _searchController.clear();
                });
              },
            ),
            body: SafeArea(
              child: Container(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: state is ChatLoading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                              : state is ChatError
                                  ? Center(child: Text(state.message, style: const TextStyle(color: Colors.red)))
                                  : ChatMessageList(
                                      messages: currentMessages,
                                      targetUserId: widget.targetUserId,
                                      scrollController: _scrollController,
                                      isSelectionMode: _isSelectionMode,
                                      selectedMessageIds: _selectedMessageIds,
                                      highlightedClientMsgId: _highlightedClientMsgId,
                                      highlightedMsgId: _highlightedMsgId,
                                      hasUnreadBelow: _hasUnreadBelow,
                                      onScrollToBottom: _scrollToBottom,
                                      onMessageTap: (msg) {
                                        if (_isSelectionMode) {
                                          setState(() {
                                            if (_selectedMessageIds.contains(msg.id)) {
                                              _selectedMessageIds.remove(msg.id);
                                              if (_selectedMessageIds.isEmpty) {
                                                _isSelectionMode = false;
                                              }
                                            } else {
                                              _selectedMessageIds.add(msg.id);
                                            }
                                          });
                                        }
                                      },
                                      onMessageLongPress: (msg) {
                                        setState(() {
                                          _isSelectionMode = true;
                                          _selectedMessageIds.add(msg.id);
                                        });
                                      },
                                    ),
                        ),
                        ChatInputBar(
                          activeChatId: _activeChatId,
                          replyingMessage: _replyingMessage,
                          editingMessage: _editingMessage,
                          isRecordingAudio: _isRecordingAudio,
                          recordingSeconds: _recordingSeconds,
                          onCancelReply: () {
                            setState(() {
                              _replyingMessage = null;
                            });
                          },
                          onCancelEditing: () {
                            setState(() {
                              _editingMessage = null;
                            });
                          },
                          onCancelAudioRecording: _cancelAudioRecording,
                          onToggleAudioRecording: () => _toggleAudioRecording(blocContext.read<ChatBloc>()),
                          onSendMessage: (text) => _sendMessage(text, blocContext.read<ChatBloc>()),
                          onOpenAttachmentSheet: () => _openAttachmentSheet(blocContext.read<ChatBloc>()),
                        ),
                      ],
                    ),
                    if (_isSearching) chatSearchWidget.buildOverlay(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
