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
  int selectedTab = 0;
  late PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.backgroundColor(context),
        leading: IconButton(
          iconSize: 24,
          color: AppColors.textColor(context),
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),

        title: Text(
          " ConVO",
          style: GoogleFonts.courgette(
            fontSize: 35,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            shadows: [],
          ),
        ),
        actions: [
          IconButton(
            color: AppColors.iconColor,
            icon: Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: SizedBox(
        width: drawerWidth,
        child: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blueGrey),
                  child: const Center(
                    child: Text(
                      "Menu",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("id");
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.backgroundColor(context),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length + 1,
                  itemBuilder: (context, index) {
                    /// 🔥 Add Story always at index 0
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () async {
                          final newStory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddStoryPage(),
                            ),
                          );

                          if (newStory != null && newStory is StoryModel) {
                            setState(() {
                              stories.insert(0, newStory); // Insert FIRST
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Column(
                            children: [
                              Container(
                                height: 65,
                                width: 65,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  child: Icon(Icons.add),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Your Story",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    /// 🔥 Real Stories
                    final story = stories[index - 1];

                    return MyStoryWidget(
                      story: story,
                      stories: stories,
                      index: index - 1,
                    );
                  },
                ),
              ),

              HomeNavbar(
                selectedIndex: selectedTab,
                onTabChanged: (index) {
                  setState(() {
                    selectedTab = index;
                  });

                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),

              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  children: const [
                    HomeChatListWidget(),
                    UnreadChatWidget(),
                    CallHistoryPage(),
                    // GroupListPage(),
                    // ChannelListPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ContactsPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); 
                      const end = Offset.zero;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: Curves.easeInOut));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
