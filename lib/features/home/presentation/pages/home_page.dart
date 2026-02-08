import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/features/auth/presentation/pages/profile_page.dart';
import 'package:convo/features/home/presentation/pages/contact_page.dart';
import 'package:convo/features/home/presentation/pages/singup_page.dart';
import 'package:convo/features/home/presentation/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      key: _scaffoldKey,
       appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        leading: 
            IconButton(
              iconSize: 24,
              color: AppColors.textColor(context),
              icon: const Icon(Icons.menu,),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            
          
        title: Text(
              " ConVO",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textColor(context),
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfilePage()));
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SingupPage()));
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
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final isAddStory = index == 0;

                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isAddStory ? Colors.grey : Colors.green,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: isAddStory
                                ? const Icon(Icons.add, size: 30)
                                : const Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAddStory ? "Your Story" : "User $index",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            child: Icon(Icons.person),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "User $index",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Last message here...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          CustomText(
                            text: "10:26",
                            bold: FontWeight.w800,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20,bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ContactsPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // 👉 from right
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));

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
