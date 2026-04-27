import 'package:flutter/material.dart';

class ReplyBar extends StatelessWidget {
  final String replyMessage;
  final VoidCallback onCancel;

  const ReplyBar({
    Key? key,
    required this.replyMessage,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Container(width: 4, height: 40, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: _buildReplyContent()),
          IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
        ],
      ),
    );
  }

  Widget _buildReplyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Replying to",
          style: TextStyle(fontSize: 12, color: Colors.blue),
        ),
        Text(
          replyMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class InputBar extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool emoji;
  final bool mssgEdit;
  final VoidCallback onEmojiToggle;
  final Function(String) onMessageChanged;
  final VoidCallback onEditMessage;
  final VoidCallback onSendMessage;
  final Color Function(BuildContext) sendButtonColor;
  final Color Function(BuildContext) backgroundColor;
  final Color iconColor;
  final Color Function(BuildContext) chatProfileColor;

  const InputBar({
    Key? key,
    required this.messageController,
    required this.focusNode,
    required this.emoji,
    required this.mssgEdit,
    required this.onEmojiToggle,
    required this.onMessageChanged,
    required this.onEditMessage,
    required this.onSendMessage,
    required this.sendButtonColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.chatProfileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: chatProfileColor(context),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          _buildEmojiButton(context),
          Expanded(child: _buildTextField(context)),
          const SizedBox(width: 8),
          _buildSendButton(context),
        ],
      ),
    );
  }

  Widget _buildEmojiButton(BuildContext context) {
    return IconButton(
      iconSize: 30,
      color: sendButtonColor(context),
      icon: Icon(emoji ? Icons.keyboard : Icons.emoji_emotions_outlined),
      onPressed: onEmojiToggle,
    );
  }

Widget _buildTextField(BuildContext context) {
  return TextField(
    controller: messageController,
    focusNode: focusNode,
    minLines: 1,
    maxLines: 4,
    onTap: null, // ✅ Remove onTap - no assignment needed
    onChanged: onMessageChanged,
    style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: "Type a message...",
      filled: true,
      fillColor: backgroundColor(context),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
  );
}
  Widget _buildSendButton(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: messageController.text.isEmpty
          ? IconButton(
              iconSize: 30,
              color: sendButtonColor(context),
              onPressed: () {},
              icon: const Icon(Icons.mic, size: 28),
            )
          : mssgEdit
              ? IconButton(
                  iconSize: 30,
                  color: sendButtonColor(context),
                  onPressed: onEditMessage,
                  icon: const Icon(Icons.check, size: 28),
                )
              : IconButton(
                  iconSize: 30,
                  color: sendButtonColor(context),
                  onPressed: onSendMessage,
                  icon: const Icon(Icons.send, size: 28),
                ),
    );
  }
}