import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/storage/secure_storage.dart';
import 'package:convo/features/chats/domain/entities/story_reply_entity.dart';
import 'package:convo/features/chats/domain/repositories/chat_repository.dart';
import 'package:convo/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:convo/features/chats/presentation/bloc/chat_event.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/features/stories/presentation/bloc/story_bloc.dart';
import 'package:convo/features/stories/presentation/bloc/story_event.dart';
import 'package:convo/features/stories/presentation/bloc/story_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class StoryViewerPage extends StatefulWidget {
  final List<UserStoryGroupEntity> storyGroups;
  final int initialGroupIndex;

  const StoryViewerPage({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late int _currentGroupIndex;
  late int _currentStoryIndex;
  late AnimationController _animController;
  VideoPlayerController? _videoPlayerController;

  bool _isPaused = false;
  bool _isVideoLoading = false;
  bool _isSendingReply = false;
  bool _hasLikedStory = false;

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  UserStoryGroupEntity get _currentGroup =>
      widget.storyGroups[_currentGroupIndex];
  List<StoryItemEntity> get _activeStories => _currentGroup.activeStories;
  StoryItemEntity get _currentStory => _activeStories[_currentStoryIndex];

  bool get _isOwner {
    final currentUserId = sl<SecureStorage>().getUserId();
    return _currentGroup.userId == 0 || _currentGroup.userId == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _currentStoryIndex = 0;

    _animController = AnimationController(vsync: this);
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _replyFocusNode.addListener(_onReplyFocusChange);
    _startStory();
  }

  void _onReplyFocusChange() {
    if (_replyFocusNode.hasFocus) {
      _pauseStory();
    } else if (!_isSendingReply) {
      _resumeStory();
    }
  }

  void _startStory() async {
    if (_activeStories.isEmpty) {
      Navigator.pop(context);
      return;
    }

    _markSeen();
    setState(() {
      _hasLikedStory = _currentStory.hasLiked;
    });

    _videoPlayerController?.dispose();
    _videoPlayerController = null;

    final isVideo = _currentStory.mediaType.toUpperCase() == 'VIDEO';

    if (isVideo && _currentStory.mediaUrl.isNotEmpty) {
      setState(() {
        _isVideoLoading = true;
      });
      _animController.stop();
      _animController.reset();

      try {
        final videoUri = Uri.parse(ApiConfig.sanitizeUrl(_currentStory.mediaUrl));
        _videoPlayerController = VideoPlayerController.networkUrl(videoUri);
        await _videoPlayerController!.initialize();
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
          });
          _animController.duration = _videoPlayerController!.value.duration;
          if (!_isPaused && !_replyFocusNode.hasFocus) {
            _videoPlayerController!.play();
            _animController.forward();
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
          });
          _animController.duration = const Duration(seconds: 5);
          if (!_isPaused && !_replyFocusNode.hasFocus) {
            _animController.forward();
          }
        }
      }
    } else {
      setState(() {
        _isVideoLoading = false;
      });
      _animController.stop();
      _animController.reset();
      _animController.duration = Duration(
        seconds: _currentStory.durationSeconds > 0
            ? _currentStory.durationSeconds
            : 5,
      );
      if (!_isPaused && !_replyFocusNode.hasFocus) {
        _animController.forward();
      }
    }
  }

  void _markSeen() {
    sl<StoryRepository>().markStoryAsSeen(
      _currentGroup.userId,
      _currentStory.id,
    );
  }

  void _nextStory() {
    if (_currentStoryIndex < _activeStories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _startStory();
    } else if (_currentGroupIndex < widget.storyGroups.length - 1) {
      setState(() {
        _currentGroupIndex++;
        _currentStoryIndex = 0;
      });
      _startStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStory();
    } else if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
        _currentStoryIndex =
            widget.storyGroups[_currentGroupIndex].activeStories.length - 1;
      });
      _startStory();
    } else {
      _startStory();
    }
  }

  void _pauseStory() {
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });
      _animController.stop();
      _videoPlayerController?.pause();
    }
  }

  void _resumeStory() {
    if (_isPaused && !_replyFocusNode.hasFocus) {
      setState(() {
        _isPaused = false;
      });
      _animController.forward();
      _videoPlayerController?.play();
    }
  }

  void _toggleLikeStory() {
    final newState = !_hasLikedStory;
    setState(() {
      _hasLikedStory = newState;
    });

    sl<StoryRepository>().toggleLikeStory(_currentStory.id, !newState);
  }

  void _showViewersSheet() {
    _pauseStory();
    final scrollController = ScrollController();
    int currentPage = 0;

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        currentPage++;
        sl<StoryBloc>().add(
          FetchStoryViewersEvent(_currentStory.id, page: currentPage),
        );
      }
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider(
        create: (_) =>
            sl<StoryBloc>()..add(FetchStoryViewersEvent(_currentStory.id, page: 0)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              BlocBuilder<StoryBloc, StoryState>(
                builder: (context, state) {
                  if (state is StoryLoading) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }
                  if (state is StoryViewersLoaded) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${state.viewCount} Views",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white12),
                          Expanded(
                            child: state.viewers.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No viewers recorded yet.",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: state.viewers.length,
                                    itemBuilder: (ctx, idx) {
                                      final v = state.viewers[idx];
                                      return ListTile(
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          if (v.userId > 0) {
                                            Navigator.pushNamed(
                                              context,
                                              RouteNames.contactProfile,
                                              arguments: {
                                                'userId': v.userId,
                                                'name': v.userName,
                                                'image': v.userProfileImage,
                                              },
                                            );
                                          }
                                        },
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              v.userProfileImage.isNotEmpty
                                                  ? NetworkImage(
                                                      ApiConfig.sanitizeUrl(
                                                        v.userProfileImage,
                                                      ),
                                                    )
                                                  : null,
                                          child: v.userProfileImage.isEmpty
                                              ? Text(
                                                  v.userName.isNotEmpty
                                                      ? v.userName[0].toUpperCase()
                                                      : "?",
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          v.userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          v.viewedAt,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: v.hasLiked
                                            ? const Icon(
                                                Icons.favorite,
                                                color: Colors.redAccent,
                                                size: 20,
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Expanded(
                    child: Center(
                      child: Text(
                        "No viewers recorded yet.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      scrollController.dispose();
      _resumeStory();
    });
  }

  void _sendStoryReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSendingReply) return;

    _isSendingReply = true;
    _pauseStory();

    final storyReplyEntity = StoryReplyEntity(
      storyId: _currentStory.id,
      mediaUrl: _currentStory.mediaUrl,
      mediaType: _currentStory.mediaType,
      createdAt: _currentStory.createdAt,
    );

    _replyController.clear();
    _replyFocusNode.unfocus();

    try {
      // Get or create 1-to-1 chat with story owner
      final chatId =
          await sl<ChatRepository>().getOrCreateChatId(_currentGroup.userId);

      // Dispatch SendMessageEvent to ChatBloc
      final chatBloc = sl<ChatBloc>();
      chatBloc.add(
        SendMessageEvent(
          chatId: chatId,
          receiverId: _currentGroup.userId,
          content: text,
          type: "STORY_REPLY",
          storyReply: storyReplyEntity,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reply sent!"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send reply: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      _isSendingReply = false;
      _resumeStory();
    }
  }

  void _confirmDeleteStory() {
    _pauseStory();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Story?"),
        content: const Text("Are you sure you want to delete this story?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              sl<StoryRepository>().deleteStory(_currentStory.id);
              _nextStory();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    ).then((_) => _resumeStory());
  }

  @override
  void dispose() {
    _replyFocusNode.removeListener(_onReplyFocusChange);
    _replyFocusNode.dispose();
    _animController.dispose();
    _videoPlayerController?.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeStories.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_replyFocusNode.hasFocus,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _replyFocusNode.hasFocus) {
          _replyFocusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
              Navigator.pop(context); // Swipe down close
            } else if (details.primaryVelocity != null &&
                details.primaryVelocity! < -300 &&
                _isOwner) {
              _showViewersSheet(); // Swipe up view viewers
            }
          },
          onLongPressStart: (_) => _pauseStory(),
          onLongPressEnd: (_) => _resumeStory(),
          child: Stack(
            children: [
              // Media Content View
              Center(
                child: _currentStory.mediaType.toUpperCase() == 'VIDEO'
                    ? (_videoPlayerController != null &&
                            _videoPlayerController!.value.isInitialized &&
                            !_isVideoLoading
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : const CircularProgressIndicator(color: Colors.white))
                    : (_currentStory.mediaUrl.isNotEmpty
                        ? Image.network(
                            ApiConfig.sanitizeUrl(_currentStory.mediaUrl),
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderMedia(),
                          )
                        : _buildPlaceholderMedia()),
              ),

              // Tap Gesture Overlay (Left = Prev, Right = Next)
              if (!_replyFocusNode.hasFocus)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _previousStory,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _nextStory,
                      ),
                    ),
                  ],
                ),

              // Top Header & Progress Segmented Bars
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Segmented Progress Bar
                      Row(
                        children: List.generate(
                          _activeStories.length,
                          (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildProgressBar(index),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Info & Profile Tap Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_currentGroup.userId > 0) {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.contactProfile,
                                  arguments: {
                                    'userId': _currentGroup.userId,
                                    'name': _currentGroup.userName,
                                    'image': _currentGroup.userImage,
                                  },
                                );
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary,
                                  backgroundImage:
                                      _currentGroup.userImage.isNotEmpty
                                          ? NetworkImage(
                                              ApiConfig.sanitizeUrl(
                                                _currentGroup.userImage,
                                              ),
                                            )
                                          : null,
                                  child: _currentGroup.userImage.isEmpty
                                      ? Text(
                                          _currentGroup.userName.isNotEmpty
                                              ? _currentGroup.userName[0]
                                                  .toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _currentGroup.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_isOwner)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: _confirmDeleteStory,
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Owner Viewers Pill or Viewer Reply Input Bar
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: keyboardHeight > 0 ? keyboardHeight + 8 : 12,
                    ),
                    child: _isOwner
                        ? GestureDetector(
                            onTap: _showViewersSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "👁 ${_currentStory.viewCount}  •  Swipe up to view",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: TextField(
                                    controller: _replyController,
                                    focusNode: _replyFocusNode,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText:
                                          "Reply to ${_currentGroup.userName}...",
                                      hintStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _hasLikedStory
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _hasLikedStory
                                      ? Colors.redAccent
                                      : Colors.white,
                                  size: 26,
                                ),
                                onPressed: _toggleLikeStory,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                onPressed: _sendStoryReply,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    if (index < _currentStoryIndex) {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (index == _currentStoryIndex) {
      return AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _animController.value,
            backgroundColor: Colors.white38,
            color: Colors.white,
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          );
        },
      );
    } else {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }

  Widget _buildPlaceholderMedia() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1E1E2C),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 80, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _currentGroup.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "ConVo Story",
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
