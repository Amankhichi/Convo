import 'package:flutter/material.dart';

class UnreadChatWidget extends StatelessWidget {
  const UnreadChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("unread is emoty"),);
    // return BlocBuilder<HomeBloc, HomeState>(
    //   builder: (context, state) {
    //     final unreadChats = state.homePageChats
    //         .where((chat) => chat.unreadCount > 0)
    //         .toList();

    //     return ListView.builder(
    //       itemCount: unreadChats.length,
    //       itemBuilder: (context, index) {
    //         final chat = unreadChats[index];
    //         return ListTile(
    //           title: Text(chat.sender.name),
    //           subtitle: Text(chat.message),
    //           trailing: CircleAvatar(
    //             radius: 12,
    //             backgroundColor: Colors.green,
    //             child: Text(
    //               chat.unreadCount.toString(),
    //               style: const TextStyle(
    //                   fontSize: 10, color: Colors.white),
    //             ),
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  
  }
}