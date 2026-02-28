import 'package:flutter/material.dart';

class ReplyPreviewWidget extends StatelessWidget {
  final String? replyMessage;
  final VoidCallback onCancel;

  const ReplyPreviewWidget({
    super.key,
    required this.replyMessage,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Replying to",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  replyMessage ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}