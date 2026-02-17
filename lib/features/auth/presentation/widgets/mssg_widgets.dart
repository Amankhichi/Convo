import 'package:flutter/material.dart';

class MssgWidgets extends StatelessWidget {
  const MssgWidgets({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    this.replyMessage,
  });

  final String message;
  final bool isMe;
  final String? replyMessage;
  final DateTime time;

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'pm' : 'am';
    return "$hour:$minute $amPm";
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.5;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicWidth(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isMe ? const Radius.circular(16) : const Radius.circular(2),
                bottomRight:
                    isMe ? const Radius.circular(2) : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Reply Message
                if (replyMessage != null &&
                    replyMessage!.trim().isNotEmpty &&
                    replyMessage != "null")
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      replyMessage!,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                /// Main Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                /// Time Row
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formatTime(time),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
