import 'package:convo/core/const.dart/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/const.dart/snakbar_status.dart';
import 'package:convo/features/home/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  final UserModel user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController;
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
      ChatEvent.sendMssg(mssg: text, receiverId: widget.user.id.toString()),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.mssgStatus == Status.success) {
          showSuccess(context, "Message sent");
        } else if (state.mssgStatus == Status.error) {
          showError(context, "Message failed");
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),

        /// APP BAR
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: AppColors.AppBarColor(context),
          elevation: 1,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
          title: ListTile(
            contentPadding: const EdgeInsets.symmetric(),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: ClipOval(
                child: Lottie.asset(widget.user.lotti, fit: BoxFit.cover),
              ),
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.user.online ? "online" : "offline",
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.user.online ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(user: widget.user)),
              );
              Divider(thickness: 0.5, color: Colors.black26);
            },
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.call, size: 25, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.videocam_rounded,
                    size: 29,
                    color: Colors.white,
                    weight: 700,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert, size: 25, color: Colors.white),
                ),
              ],
            ),
          ],
        ),

        

        /// BODY
        body: Container(
          decoration: BoxDecoration(
            image:isDeviceThemeDark(context)? DecorationImage(
              image: AssetImage("assests/wallpapers/DarkThem.png"),
              fit: BoxFit.cover, 
            ):DecorationImage(
              image: AssetImage("assests/wallpapers/LightThem.png"),
              fit: BoxFit.cover, 
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  children: const [
                    // You’ll add messages here later
                  ],
                ),
              ),

              /// INPUT BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.AppBarColor(context),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      color: AppColors.background(context),
                      icon: const Icon(Icons.emoji_emotions_outlined, size: 29),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: TextStyle(
                          color: AppColors.invertTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundColor(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: _messageController.text.isNotEmpty
                          ? IconButton(
                              color: AppColors.background(context),
                              icon: const Icon(Icons.send, size: 30),
                              onPressed: _sendMessage,
                            )
                          : IconButton(
                              color: AppColors.background(context),
                              icon: const Icon(Icons.mic, size: 30),
                              onPressed: () {},
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
