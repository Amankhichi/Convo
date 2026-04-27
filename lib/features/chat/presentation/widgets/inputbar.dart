import 'package:convo/core/const.dart/app_colors.dart';
import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool emoji;
  final bool mssgEdit;
  final VoidCallback onEmojiToggle;
  final Function(String) onMessageChanged;
  final VoidCallback onEditMessage;
  final VoidCallback onSendMessage;
  final Color? sendButtonColor;
  final Color Function(BuildContext)? backgroundColorFn;
  final Color iconColor;
  final Color Function(BuildContext)? chatProfileColorFn;

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
    this.sendButtonColor,
    this.backgroundColorFn,
    required this.iconColor,
    this.chatProfileColorFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: _getContainerColor(context), // ✅ Use single method
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

  /// ✅ Single method for container color (chat profile color)
  Color _getContainerColor(BuildContext context) {
    return chatProfileColorFn != null 
        ? chatProfileColorFn!(context) 
        : AppColors.chatProfileColor(context);
  }

  /// ✅ Send button color
  Color _getSendButtonColor(BuildContext context) {
    return sendButtonColor ?? AppColors.sendBT(context);
  }

  /// ✅ Background color for text field
  Color _getBackgroundColor(BuildContext context) {
    return backgroundColorFn != null 
        ? backgroundColorFn!(context) 
        : AppColors.backgroundColor(context);
  }

  Widget _buildEmojiButton(BuildContext context) {
    return IconButton(
      iconSize: 30,
      color: _getSendButtonColor(context),
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
    onTap: () {
      // ✅ Removed: emoji = false (can't modify final emoji)
      // Toggle handled by onEmojiToggle callback instead
    },
    onChanged: onMessageChanged,
    style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: "Type a message...",
      filled: true,
      fillColor: _getBackgroundColor(context),
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
              color: _getSendButtonColor(context),
              onPressed: () {},
              icon: const Icon(Icons.mic, size: 28),
            )
          : mssgEdit
              ? IconButton(
                  iconSize: 30,
                  color: _getSendButtonColor(context),
                  onPressed: onEditMessage,
                  icon: const Icon(Icons.check, size: 28),
                )
              : IconButton(
                  iconSize: 30,
                  color: _getSendButtonColor(context),
                  onPressed: onSendMessage,
                  icon: const Icon(Icons.send, size: 28),
                ),
    );
  }
}