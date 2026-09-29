import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';

class TextMessageWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const TextMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      message.content,
      style: TextStyle(
        fontSize: 15,
        height: 1.35,
        color: isMe ? Colors.white : AppColors.textColor(context),
      ),
    );
  }
}
