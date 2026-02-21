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
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final ap = time.hour >= 12 ? 'pm' : 'am';
    return "$h:$m $ap";
  }

  bool isOnlyEmojis(String t) => RegExp(
    r'^[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F1E6}-\u{1F1FF}\s]+$',
    unicode: true,
  ).hasMatch(t.trim());

  int emojiCount(String t) => RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
    unicode: true,
  ).allMatches(t).length;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.7;
    final onlyEmoji = isOnlyEmojis(message);
    final count = emojiCount(message);

    double emojiSize = 15;
    if (onlyEmoji && count == 1) emojiSize = 40;
    if (onlyEmoji && count > 1) emojiSize = 30;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicWidth(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            padding: onlyEmoji
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: onlyEmoji
                  ? Colors.transparent
                  : (isMe ? Colors.blue : Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe
                    ? const Radius.circular(16)
                    : const Radius.circular(2),
                bottomRight: isMe
                    ? const Radius.circular(2)
                    : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Reply bubble
                if (replyMessage != null && replyMessage!.trim().isNotEmpty)
                  IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(width: 3, color: Colors.white),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              replyMessage!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// Message Text / Emoji
                Text(
                  message,
                  style: TextStyle(
                    fontSize: onlyEmoji ? emojiSize : 15,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                /// Time + Tick
                Align(
                  alignment: isMe
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(time),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isMe)
                        Row(
                          children: const [
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "seen",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                    ],
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
