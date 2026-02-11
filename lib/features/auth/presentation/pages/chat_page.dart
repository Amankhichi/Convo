import 'package:convo/core/const.dart/constant.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/features/home/presentation/bloc/singup_bloc/singup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/const.dart/app_colors.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool isMe = false;
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    Future.delayed(const Duration(microseconds: 1), () async {
      context.read<ChatBloc>().add(
        ChatEvent.getMssg(receiverId: widget.user.id.toString()),
      );
    });

    Future.delayed(Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });

    _sendMessage();
  }

  void _sendMessage() {
    Future.delayed(const Duration(microseconds: 1), () async {
      final text = _messageController.text.trim();
      if (text.isEmpty) return;
      context.read<ChatBloc>().add(
        ChatEvent.sendMssg(mssg: text, receiverId: widget.user.id.toString()),
      );
      _messageController.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        height: double.infinity,
        decoration: BoxDecoration(
          image: isDeviceThemeDark(context)
              ? DecorationImage(
                  image: AssetImage("assests/wallpapers/DarkThem.png"),
                  // fit: BoxFit.cover,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                )
              : DecorationImage(
                  image: AssetImage("assests/wallpapers/LightThem.png"),
                  fit: BoxFit.fitWidth,
                ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<SingupBloc, SingupState>(
                builder: (context, sstate) {
                  return Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        final profile = context
                            .read<SingupBloc>()
                            .state
                            .profile;

                        if (state.GetMssgStatus == Status.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.messages.isEmpty) {
                          return const Center(child: Text("No messages"));
                        }

                        return ListView.builder(
                          reverse: true,
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final msg = state.messages[state.messages.length - index - 1];

                            final bool isMe =
                                msg.senderId == profile?.id.toString();
                            print("msg.senderId: ${msg.senderId}");
                            print("profile.id: ${profile?.id}");
                            print("isMe: $isMe");

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.message, // ✅ SHOW REAL MESSAGE
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            /// INPUT BAR
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                      focusNode: _focusNode,
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
                        hintText: "Type is message",
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
    );
  }
}
