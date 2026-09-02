import 'package:convo/features/chats/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';

class MessageStatusWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageStatusWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    final statusUpper = message.status.toUpperCase();

    if (statusUpper == 'PENDING' || statusUpper == 'SENDING' || statusUpper == 'UPLOADING') {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.access_time,
          size: 13,
          color: Colors.white70,
        ),
      );
    } else if (statusUpper == 'FAILED') {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.warning_amber_rounded,
          size: 14,
          color: Colors.redAccent,
        ),
      );
    } else if (message.seen || statusUpper == 'SEEN') {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.done_all,
          size: 15,
          color: Color(0xFF64B5F6),
        ),
      );
    } else if (statusUpper == 'DELIVERED') {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.done_all,
          size: 15,
          color: Colors.white70,
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.check,
          size: 15,
          color: Colors.white70,
        ),
      );
    }
  }
}
