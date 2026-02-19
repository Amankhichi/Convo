import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ContactUserProfilePage extends StatelessWidget {
   ContactUserProfilePage({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.AppBarColor(context),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert,color: Colors.white,),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 🔥 Avatar with Glow Border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.blue, Colors.green],
                ),
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.black,
                child: Lottie.asset(user.lotti, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 15),

            /// Name
            Text(
              user.nickName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              ),
            ),

            const SizedBox(height: 5),

            /// Status
            Text(
              user.online ? "Online" : "Offline",
              style: TextStyle(
                color: user.online ?  Colors.green : Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w900
              ),
            ),

            const SizedBox(height: 25),

            /// 🔥 Action Buttons Glass Style
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _modernAction(context, Icons.call, "Call"),
                _modernAction(context, Icons.videocam, "Video"),
                _modernAction(context, Icons.chat, "Message"),
              ],
            ),

            const SizedBox(height: 30),

            /// 🔥 About Card
            _glassCard(
              context,
              title: "About",
              child: Text(
                user.about,
                style: const TextStyle(color: Colors.white70, fontSize: 18,fontWeight: FontWeight.w600),
              ),
            ),

            /// 🔥 Phone Card
            _glassCard(
              context,
              title: "Phone",
              child: const Text(
                "+91 1234567890",
                style: TextStyle(color: Colors.white70, fontSize: 18,fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _glassCard(BuildContext context,{ required String title, required Widget child}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 4),
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.AppBarColor(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 3,),
        child,
      ],
    ),
  );
}


Widget _modernAction(BuildContext context,IconData icon, String title) {
  return Column(
    children: [
      Container(
        
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.AppBarColor(context),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

}
