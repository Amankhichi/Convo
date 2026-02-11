import 'package:flutter/material.dart';

class MssgWidgets extends StatelessWidget {
  const MssgWidgets({super.key, this.message, required this.isMe});
  final message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
);
  }
}