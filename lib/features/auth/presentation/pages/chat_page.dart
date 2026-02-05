import 'package:flutter/material.dart';
import 'package:convo/core/const.dart/app_colors.dart';

class ChatPage extends StatelessWidget {
  // final String userName;

  const ChatPage(String string, {super.key, });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),

      /// 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.matchTheme(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,weight: 800,),
          color: AppColors.primary,
          iconSize: 25,
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                "userName[0]".toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "userName",
                  style: TextStyle(
                    color: AppColors.textColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "online",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.call),
          SizedBox(width: 16),
          Icon(Icons.videocam),
          SizedBox(width: 8),
        ],
      ),

      /// 💬 BODY
      body: Column(
        children: [
          /// MESSAGES
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                // ChatBubble(
                //   message: "Hey 👋",
                //   isMe: false,
                //   time: "10:20 AM",
                // ),
                // ChatBubble(
                //   message: "Hi! How are you?",
                //   isMe: true,
                //   time: "10:21 AM",
                // ),
                // ChatBubble(
                //   message: "I'm good, working on the app 😄",
                //   isMe: false,
                //   time: "10:22 AM",
                // ),
                // ChatBubble(
                //   message: "Nice! UI looks clean 🔥",
                //   isMe: true,
                //   time: "10:23 AM",
                // ),
              ],
            ),
          ),

          /// ✏️ MESSAGE INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.matchTheme(context),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.grey[850],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
