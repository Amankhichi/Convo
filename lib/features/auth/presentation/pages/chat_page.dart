import 'package:convo/core/model/user_model.dart';
import 'package:convo/features/home/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final UserModel users;

   ChatPage( {super.key, required this.users,});

  TextEditingController mssg=TextEditingController();
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
                 users.id.toString(),
                // "userName[0]".toUpperCase(),
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
                  users.name,
                  style: TextStyle(
                    color: AppColors.textColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  // users.online.bool,
                  "jg",
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
                    onTap: () {
                      context.read<ChatBloc>().add(ChatEvent.sendMssg(mssg: mssg.text,  receiverId: users.id.toString()));
                    },
                      controller: mssg,
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
