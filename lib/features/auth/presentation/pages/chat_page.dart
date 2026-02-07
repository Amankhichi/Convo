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
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: LottieBuilder.asset(widget.user.lotti),
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
        ),

        /// BODY
        body: Column(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.AppBarColor(context),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
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
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        filled: true,
                        fillColor: Colors.grey[900],
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
                    backgroundColor: AppColors.textColor(context),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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
