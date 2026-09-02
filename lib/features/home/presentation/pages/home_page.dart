import 'package:convo/app/config/api_config.dart';
import 'package:convo/app/router/route_names.dart';
import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/core/widgets/app_scaffold.dart';
import 'package:convo/core/widgets/user_profile_preview_dialog.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';
import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';
import 'package:convo/features/home/presentation/bloc/home_bloc.dart';
import 'package:convo/features/home/presentation/bloc/home_event.dart';
import 'package:convo/features/home/presentation/bloc/home_state.dart';
import 'package:convo/features/stories/domain/entities/story_entity.dart';
import 'package:convo/features/stories/domain/repositories/story_repository.dart';
import 'package:convo/features/stories/presentation/pages/story_viewer_page.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFilter = 'ALL';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['ALL', 'UNREAD', 'CALL', 'GROUPS', 'CHAT'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      if (dateTime.day == now.day &&
          dateTime.month == now.month &&
          dateTime.year == now.year) {
        return DateFormat('hh:mm a').format(dateTime);
      }
      return DateFormat('dd/MM/yy').format(dateTime);
    } catch (_) {
      return "";
    }
  }

  List<ChatSummaryEntity> _filterChats(List<ChatSummaryEntity> chats) {
    return chats.where((chat) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = chat.targetUserName.toLowerCase().contains(query);
        final matchesMsg = chat.lastMessageContent.toLowerCase().contains(
          query,
        );
        if (!matchesName && !matchesMsg) return false;
      }

      // Tab filter
      if (_selectedFilter == 'UNREAD') {
        return chat.unreadCount > 0;
      } else if (_selectedFilter == 'GROUPS') {
        return chat.chatType.toUpperCase() == 'GROUP';
      } else if (_selectedFilter == 'CHAT') {
        return chat.chatType.toUpperCase() == 'DIRECT';
      }

      return true;
    }).toList();
  }

  void _openFabActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00A3FF),
                    child: Icon(Icons.chat, color: Colors.white),
                  ),
                  title: const Text(
                    "New Chat",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Start a conversation with a contact"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, RouteNames.contacts);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.group_add, color: Colors.white),
                  ),
                  title: const Text(
                    "New Group",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Create a group chat"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, RouteNames.contacts);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.call, color: Colors.white),
                  ),
                  title: const Text(
                    "Start Call",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Make a voice or video call"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, RouteNames.contacts);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text(
                    "Create Story",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Share a photo or video story"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, RouteNames.media);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF131317)
        : AppColors.backgroundLight;

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(FetchHomeChatsEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return AppScaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 16,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search chats & contacts...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    )
                  : Text(
                      "ConVo",
                      style: GoogleFonts.pacifico(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00A3FF),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: isDark ? Colors.white : AppColors.primary,
                    size: 26,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchController.clear();
                        _searchQuery = '';
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.white : AppColors.primary,
                    size: 26,
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.of(context).pushNamed(RouteNames.profile);
                    } else if (value == 'new_group') {
                      Navigator.of(context).pushNamed(RouteNames.contacts);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'new_group',
                          child: Text('New group'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'new_broadcast',
                          child: Text('New broadcast'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'linked_devices',
                          child: Text('Linked devices'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'starred',
                          child: Text('Starred messages'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('Settings / Profile'),
                        ),
                      ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: RefreshIndicator(
              color: const Color(0xFF00A3FF),
              onRefresh: () async {
                context.read<HomeBloc>().add(FetchHomeChatsEvent());
              },
              child: Container(
                color: backgroundColor,
                child: Column(
                  children: [
                    // Stories / Status Bar
                    _buildStoriesRow(state, isDark),

                    const SizedBox(height: 12),

                    // Filter Chips Bar
                    _buildFilterChips(isDark),

                    const SizedBox(height: 12),

                    // Main Content List (Chats or Calls)
                    Expanded(
                      child: _selectedFilter == 'CALL'
                          ? _buildCallHistoryList(isDark)
                          : _buildHomeBody(context, state, isDark),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 4,
              backgroundColor: const Color(0xFF00A3FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () => _openFabActionSheet(context),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          );
        },
      ),
    );
  }

  /// Story / Status Bar Component
  Widget _buildStoriesRow(HomeState state, bool isDark) {
    final storyRepo = sl<StoryRepository>();
    final storyGroups = storyRepo.getStoryGroups();

    List<ChatSummaryEntity> chats = [];
    if (state is HomeLoaded) {
      chats = state.chats;
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // My Status Add Circle
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.media);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF23232C)
                            : const Color(0xFFEAEAEA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF8B5CF6),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "My Story",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Story Groups
          if (storyGroups.isNotEmpty)
            ...storyGroups.asMap().entries.map((entry) {
              final idx = entry.key;
              final group = entry.value;

              return _buildStoryGroupCircle(
                group: group,
                isDark: isDark,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewerPage(
                        storyGroups: storyGroups,
                        initialGroupIndex: idx,
                      ),
                    ),
                  );
                  setState(() {});
                },
              );
            })
          else ...[
            // Fallback story circles generated from chat users if no stories created yet
            ...chats.take(4).map((chat) {
              final dummyGroup = UserStoryGroupEntity(
                userId: chat.targetUserId,
                userName: chat.targetUserName,
                userImage: chat.targetUserImage,
                stories: [
                  StoryItemEntity(
                    id: chat.chatId.toString(),
                    mediaUrl: chat.targetUserImage,
                    createdAt: chat.lastMessageTime,
                    isSeen: false,
                  ),
                ],
              );

              return _buildStoryGroupCircle(
                group: dummyGroup,
                isDark: isDark,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewerPage(
                        storyGroups: [dummyGroup],
                        initialGroupIndex: 0,
                      ),
                    ),
                  );
                  setState(() {});
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStoryGroupCircle({
    required UserStoryGroupEntity group,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final hasUnseen = group.hasUnseenStories;
    final displayName = group.userName.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasUnseen ? Colors.green : Colors.grey.shade600,
                  width: hasUnseen ? 2.5 : 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE2D6FF),
                  backgroundImage: group.userImage.isNotEmpty
                      ? NetworkImage(ApiConfig.sanitizeUrl(group.userImage))
                      : null,
                  child: group.userImage.isEmpty
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Color(0xFF5B21B6),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 66,
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasUnseen ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter Chips Component
  Widget _buildFilterChips(bool isDark) {
    return SizedBox(
      height: 42, // Adjusted height to comfortably fit padding + text
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00A3FF)
                      : (isDark ? Colors.transparent : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark ? Colors.white70 : Colors.grey.shade400,
                          width: 1,
                        ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Main Chat List Body
  Widget _buildHomeBody(BuildContext context, HomeState state, bool isDark) {
    if (state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00A3FF)),
      );
    }

    if (state is HomeLoaded) {
      final filteredChats = _filterChats(state.chats);

      if (filteredChats.isEmpty) {
        return _buildEmptyState(context, isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          final chat = filteredChats[index];

          return Container(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),

              // Avatar click opens Centered User Profile Preview Dialog!
              leading: GestureDetector(
                onTap: () {
                  UserProfilePreviewDialog.show(
                    context,
                    userId: chat.targetUserId,
                    name: chat.targetUserName,
                    phone: chat.targetUserPhone,
                    image: chat.targetUserImage,
                    about: chat.targetUserAbout,
                    isOnline: chat.online,
                    chatId: chat.chatId,
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF23232C),
                          backgroundImage: chat.targetUserImage.isNotEmpty
                              ? NetworkImage(
                                  ApiConfig.sanitizeUrl(chat.targetUserImage),
                                )
                              : null,
                          child: chat.targetUserImage.isEmpty
                              ? Text(
                                  chat.targetUserName.isNotEmpty
                                      ? chat.targetUserName[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (chat.online)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF131317)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chat.targetUserName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? Colors.white
                            : AppColors.textColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTime(chat.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: chat.unreadCount > 0
                          ? const Color(0xFF00A3FF)
                          : (isDark
                                ? Colors.white54
                                : AppColors.greyText(context)),
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.lastMessageContent.isNotEmpty
                            ? chat.lastMessageContent
                            : chat.targetUserAbout.isNotEmpty
                            ? chat.targetUserAbout
                            : "Tap to chat",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: chat.unreadCount > 0
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                    ? Colors.white60
                                    : AppColors.greyText(context)),
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (chat.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A3FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          chat.unreadCount > 99
                              ? "99+"
                              : chat.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Chat tile tap opens main chat screen
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  RouteNames.chat,
                  arguments: {
                    "chatId": chat.chatId,
                    "targetUserId": chat.targetUserId,
                    "contactName": chat.targetUserName,
                    "contactPhone": chat.targetUserPhone,
                    "contactImage": chat.targetUserImage,
                    "contactAbout": chat.targetUserAbout,
                    "online": chat.online,
                  },
                );
                if (context.mounted) {
                  context.read<HomeBloc>().add(FetchHomeChatsEvent());
                }
              },
            ),
          );
        },
      );
    }

    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.message, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(FetchHomeChatsEvent()),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Call History List (for CALL tab)
  Widget _buildCallHistoryList(bool isDark) {
    final callLogs = sl<CallRepository>().getCallLogs();

    if (callLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_missed_outlined,
              size: 70,
              color: isDark
                  ? Colors.white38
                  : AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No recent calls",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your voice and video call history will appear here",
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.greyText(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: callLogs.length,
      itemBuilder: (context, index) {
        final log = callLogs[index];

        IconData directionIcon;
        Color directionColor;

        if (log.direction == 'INCOMING') {
          directionIcon = Icons.call_received;
          directionColor = Colors.green;
        } else if (log.direction == 'OUTGOING') {
          directionIcon = Icons.call_made;
          directionColor = const Color(0xFF00A3FF);
        } else if (log.direction == 'MISSED') {
          directionIcon = Icons.call_missed;
          directionColor = Colors.red;
        } else {
          directionIcon = Icons.call_end;
          directionColor = Colors.orange;
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: log.targetUserImage.isNotEmpty
                ? NetworkImage(ApiConfig.sanitizeUrl(log.targetUserImage))
                : null,
            child: log.targetUserImage.isEmpty
                ? Text(
                    log.targetUserName.isNotEmpty
                        ? log.targetUserName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          title: Text(
            log.targetUserName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textColor(context),
            ),
          ),
          subtitle: Row(
            children: [
              Icon(directionIcon, size: 16, color: directionColor),
              const SizedBox(width: 6),
              Text(
                "${log.callType} Call • ${_formatTime(log.timestamp)}",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.greyText(context),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              log.callType == 'VIDEO' ? Icons.videocam : Icons.call,
              color: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.calling);
            },
          ),
        );
      },
    );
  }

  /// Tailored Empty States per filter
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    String emptyText = "No conversations yet";
    String subText = "Tap + below to start a new chat";

    if (_searchQuery.isNotEmpty) {
      emptyText = "No results for '$_searchQuery'";
      subText = "Check your spelling or try another keyword";
    } else if (_selectedFilter == 'UNREAD') {
      emptyText = "No unread messages";
      subText = "All your conversations are up to date";
    } else if (_selectedFilter == 'GROUPS') {
      emptyText = "No groups yet";
      subText = "Create or join a group to start chatting";
    } else if (_selectedFilter == 'CHAT') {
      emptyText = "No 1-to-1 chats yet";
      subText = "Start a direct conversation with a contact";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 70,
            color: isDark
                ? Colors.white38
                : AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subText,
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.greyText(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
