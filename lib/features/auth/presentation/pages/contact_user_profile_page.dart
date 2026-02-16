import 'package:flutter/material.dart';
import 'package:lottie/src/lottie_builder.dart';

class ContactUserProfilePage extends StatelessWidget {
  const ContactUserProfilePage({super.key, required LottieBuilder child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Profile"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/300",
              ),
            ),

            const SizedBox(height: 16),

            /// Name
            const Text(
              "Aman Khichi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            /// Status
            const Text(
              "Online",
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),

            const SizedBox(height: 20),

            /// Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.call, "Call"),
                _actionButton(Icons.videocam, "Video"),
                _actionButton(Icons.chat, "Message"),
              ],
            ),

            const SizedBox(height: 30),

            /// Info Card
            _infoCard(
              title: "About",
              child: const Text(
                "Flutter Developer | BCA Student | Building Chat App 🚀",
              ),
            ),

            _infoCard(
              title: "Phone",
              child: const Text("+91 9876543210"),
            ),

            _infoCard(
              title: "Email",
              child: const Text("aman@gmail.com"),
            ),

            _infoCard(
              title: "Media, Links and Docs",
              child: Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Action Button Widget
Widget _actionButton(IconData icon, String title) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade900,
        ),
        child: Icon(icon, size: 28, color: Colors.white),
      ),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(fontSize: 12)),
    ],
  );
}

/// Info Card Widget
Widget _infoCard({required String title, required Widget child}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade900,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}
