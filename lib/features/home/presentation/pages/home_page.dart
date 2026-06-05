import 'package:convo/const.dart/app_colors.dart';
import 'package:convo/core/model/stroy_model.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
import 'package:convo/features/auth/presentation/pages/login_page.dart';
import 'package:convo/features/auth/presentation/pages/profile_page.dart';
import 'package:convo/features/contact/presentation/pages/contact_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:convo/features/home/presentation/pages/add_stroy_page.dart';
import 'package:convo/features/home/presentation/pages/all_chat_page.dart';
import 'package:convo/features/home/presentation/pages/call_history_page.dart';
import 'package:convo/features/home/presentation/pages/unread_mssg_chat_page.dart';
import 'package:convo/features/home/presentation/widgets/home_app_bar_widget.dart';
import 'package:convo/features/home/presentation/widgets/home_drawer_widget.dart';
import 'package:convo/features/home/presentation/widgets/home_navbar_widget.dart';
import 'package:convo/features/home/presentation/widgets/my_story_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late PageController _pageController;

  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  int selectedTab = 0;

  Set<int> selectedChats = {};
  bool selectionMode = false;

  late UserModel user;

  final List<StoryModel> stories = [
    StoryModel(
      username: "Rahul",
      imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
      isMyStory: false,
    ),
    StoryModel(
      username: "Aman",
      imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
      isMyStory: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    user = context.read<LoginBloc>().state.profile!;

    context.read<LoginBloc>().add(
      LoginEvent.setOnline(userId: user.id, online: true),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _pageController.dispose();

    context.read<LoginBloc>().add(
      LoginEvent.setOnline(userId: user.id, online: false),
    );

    super.dispose();
  }

  /// ✅ SWIPE REFRESH
  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const HomeEvent.init());
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void onSearch(String value) {
    setState(() => searchQuery = value);
  }

  void clearSearch() {
    setState(() {
      searchQuery = "";
      searchController.clear();
      isSearching = false;
    });
  }

  void changeTab(int index) {
    setState(() => selectedTab = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleChat(int id) {
    setState(() {
      if (selectedChats.contains(id)) {
        selectedChats.remove(id);
      } else {
        selectedChats.add(id);
      }
      selectionMode = selectedChats.isNotEmpty;
    });
  }

  void clearSelection() {
    setState(() {
      selectedChats.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final filteredChats = searchQuery.trim().isEmpty
            ? state.homePageChats
            : state.homePageChats.where((chat) {
                final currentUserId = user.id;

                final chatUser = chat.sender.id == currentUserId
                    ? chat.receiver
                    : chat.sender;

                final q = searchQuery.toLowerCase().trim();

                return chatUser.name.toLowerCase().contains(q) ||
                    chatUser.nickname.toLowerCase().contains(q) ||
                    chatUser.phone.toLowerCase().contains(q) ||
                    chat.message.toLowerCase().contains(q);
              }).toList();

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundColor(context),

          appBar: HomeAppBarWidget(
            isSearching: isSearching,
            searchController: searchController,
            onSearch: onSearch,
            onSearchTap: () => setState(() => isSearching = true),

            selectionMode: selectionMode,
            selectedCount: selectedChats.length,

            onBackTap: () {
              if (selectionMode) {
                clearSelection();
              } else {
                clearSearch();
              }
            },

            onMenuTap: () => _scaffoldKey.currentState!.openDrawer(),

            onDeleteTap: () {},
            onStarTap: () {},
          ),

          drawer: HomeDrawerWidget(
            user: user,
            onProfileTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            onSettingsTap: () => Navigator.pop(context),
            onAboutTap: () => Navigator.pop(context),
            onLogout: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),

          body: SafeArea(
            child: Column(
              children: [
                if (!isSearching) _buildStories(),

                HomeNavbar(selectedIndex: selectedTab, onTabChanged: changeTab),

                const SizedBox(height: 10),

                /// ✅ SWIPE TO REFRESH ONLY CHAT AREA
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.backgroundColor(context),
                    onRefresh: _onRefresh,

                    child: PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) {
                        setState(() => selectedTab = i);
                      },
                      children: [
                        AllChatPage(
                          chats: filteredChats,
                          selectedChats: selectedChats,
                          selectionMode: selectionMode,
                          onSelect: toggleChat,
                        ),
                        const UnreadMssgChatPage(),
                        const CallHistoryPage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: _buildFAB(),
        );
      },
    );
  }

  /// STORIES
  Widget _buildStories() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return GestureDetector(
              onTap: () async {
                final newStory = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStoryPage()),
                );

                if (newStory is StoryModel) {
                  setState(() => stories.insert(0, newStory));
                }
              },
              child: _myStoryWidget(),
            );
          }

          return MyStoryWidget(
            story: stories[i - 1],
            stories: stories,
            index: i - 1,
          );
        },
      ),
    );
  }

  Widget _myStoryWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: const CircleAvatar(child: Icon(Icons.add)),
          ),
          const SizedBox(height: 6),
          Text(
            "Your Story",
            style: TextStyle(fontSize: 13, color: AppColors.textColor(context)),
          ),
        ],
      ),
    );
  }

  /// FAB
  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 20),
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactsPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
