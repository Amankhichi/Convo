import 'package:convo/app/config/api_config.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';

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
  bool _isPaused = false;

  UserStoryGroupEntity get _currentGroup =>
      widget.storyGroups[_currentGroupIndex];
  List<StoryItemEntity> get _activeStories => _currentGroup.activeStories;
  StoryItemEntity get _currentStory => _activeStories[_currentStoryIndex];

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

    _startStory();
  }

  void _startStory() {
    if (_activeStories.isEmpty) {
      Navigator.pop(context);
      return;
    }

    _markSeen();

    _animController.stop();
    _animController.reset();
    _animController.duration = Duration(
      seconds: _currentStory.durationSeconds > 0
          ? _currentStory.durationSeconds
          : 5,
    );
    _animController.forward();
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
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeStories.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            Navigator.pop(context);
          }
        },
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
        child: Stack(
          children: [
            // Media Content View
            Center(
              child: _currentStory.mediaUrl.isNotEmpty
                  ? Image.network(
                      ApiConfig.sanitizeUrl(_currentStory.mediaUrl),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholderMedia(),
                    )
                  : _buildPlaceholderMedia(),
            ),

            // Tap gesture overlay (Left = Previous, Right = Next)
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

            // Top Progress Bars & User Header
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

                    // User Info Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple.shade300,
                          backgroundImage: _currentGroup.userImage.isNotEmpty
                              ? NetworkImage(
                                  ApiConfig.sanitizeUrl(_currentGroup.userImage))
                              : null,
                          child: _currentGroup.userImage.isEmpty
                              ? Text(
                                  _currentGroup.userName.isNotEmpty
                                      ? _currentGroup.userName[0].toUpperCase()
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
                              Shadow(blurRadius: 4, color: Colors.black54)
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
