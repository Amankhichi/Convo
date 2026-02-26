import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/stroy_model.dart';
import 'package:convo/features/auth/presentation/pages/profile_page.dart';
import 'package:convo/features/contact/presentation/pages/contact_page.dart';
import 'package:convo/features/auth/presentation/pages/login_page.dart';
import 'package:convo/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:convo/features/home/presentation/widgets/home_chat_list_widget.dart';
import 'package:convo/features/home/presentation/widgets/my_story_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<StoryModel> stories = [
    StoryModel(
      username: "You",
      imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
      isMyStory: true,
    ),
    StoryModel(
      username: "Aman",
      imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    ),
    StoryModel(
      username: "Rahul",
      imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
    ),
  ];
  @override
  void initState() {
    super.initState();

    context.read<HomeBloc>().add(HomeEvent.init());
  }

  @override
  void dispose() {
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
          Icon(Icons.search, size: 35, color: AppColors.iconColor(context)),
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
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => LoginPage()));
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("id");
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: AppColors.backgroundColor(context),
        child: Column(
          children: [
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  return MyStoryWidget(
                    story: stories[index],
                    stories: stories,
                    index: index,
                  );
                },
              ),
            ),
            Expanded(child: HomeChatListWidget()),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ContactsPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // 👉 from right
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
