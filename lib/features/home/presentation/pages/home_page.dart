import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/stroy_model.dart';
import 'package:convo/features/auth/presentation/pages/profile_page.dart';
import 'package:convo/features/contact/presentation/pages/contact_page.dart';
import 'package:convo/features/auth/presentation/pages/login_page.dart';
import 'package:convo/features/home/presentation/pages/add_stroy_page.dart';
import 'package:convo/features/home/presentation/pages/call_history_page.dart';
import 'package:convo/features/home/presentation/widgets/home_chat_list_widget.dart';
import 'package:convo/features/home/presentation/widgets/home_navbar_widget.dart';
import 'package:convo/features/home/presentation/widgets/my_story_widget.dart';
import 'package:convo/features/home/presentation/widgets/unread_chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;

  int selectedTab = 0;
  Set<int> selectedChats = {};
  bool selectionMode = false;

  final List<StoryModel> stories = [
    StoryModel(
      username: "Sumurk sir",
      imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
      isMyStory: false,
    ),
    StoryModel(
      username: "Rahul",
      imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
      isMyStory: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleChat(int id) {
    setState(() {
      selectedChats.contains(id)
          ? selectedChats.remove(id)
          : selectedChats.add(id);
      selectionMode = selectedChats.isNotEmpty;
    });
  }

  void clearSelection() {
    setState(() {
      selectedChats.clear();
      selectionMode = false;
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

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("id");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final drawerWidth = MediaQuery.of(context).size.width * .5;

    return Scaffold(
      key: _scaffoldKey,

      appBar: _buildAppBar(),

      drawer: _buildDrawer(drawerWidth),

      body: SafeArea(
        child: Container(
          color: AppColors.backgroundColor(context),
          child: Column(
            children: [

              _buildStories(),

              HomeNavbar(
                selectedIndex: selectedTab,
                onTabChanged: changeTab,
              ),

              const SizedBox(height: 10),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => selectedTab = i),
                  children: [
                    HomeChatListWidget(
                      selectedChats: selectedChats,
                      selectionMode: selectionMode,
                      onSelect: toggleChat,
                    ),
                    const UnreadChatWidget(),
                    const CallHistoryPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: _buildFAB(),
    );
  }

  /// ---------------- APPBAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: AppColors.backgroundColor(context),

      leading: selectionMode
          ? IconButton(
            color: AppColors.iconColor,
              icon: const Icon(Icons.arrow_back),
              onPressed: clearSelection,
            )
          : IconButton(
              icon: const Icon(Icons.menu),
              color: AppColors.textColor(context),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),

      title: selectionMode
          ? Text("${selectedChats.length} selected",style: TextStyle(color: AppColors.iconColor),)
          : Text(
              " ConVO",
              style: GoogleFonts.courgette(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),

      actions: selectionMode
          ? [
              IconButton(color: AppColors.iconColor, icon: const Icon(Icons.star), onPressed: () {}),
              IconButton(color: AppColors.iconColor, icon: const Icon(Icons.delete), onPressed: () {}),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search, size: 28),
                color: AppColors.iconColor,
                onPressed: () {},
              ),
              const SizedBox(width: 10),
            ],
    );
  }

  /// ---------------- DRAWER ----------------
  Widget _buildDrawer(double width) {
    return SizedBox(
      width: width,
      child: Drawer(
        child: Column(
          children: [

            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
            ),

            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- STORIES ----------------
  Widget _buildStories() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
          const Text("Your Story", style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  /// ---------------- FAB ----------------
  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 20),
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ContactsPage(),
              transitionsBuilder: (_, animation, __, child) =>
                  SlideTransition(
                position: Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
