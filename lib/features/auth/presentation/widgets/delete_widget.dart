import 'package:flutter/material.dart';

class DeleteWidget extends StatelessWidget {
  final dynamic msg;   // or your MessageModel type

  const DeleteWidget({
    super.key,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete message"),
            onTap: () {
              Navigator.pop(context);

              // context.read<ChatBloc>().add(
              //   DeleteMessageEvent(msg.id),
              // );
            },
          ),
        ],
      ),
    );
  }
}