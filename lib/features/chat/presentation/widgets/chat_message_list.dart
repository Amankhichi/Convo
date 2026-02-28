// import 'package:convo/features/chat/presentation/widgets/mssg_widgets.dart';
// import 'package:flutter/material.dart';

// class ChatMessageList extends StatelessWidget {
//    ChatMessageList({
//     super.key,
//     required this.messages,
//     required this.profileId,
//     required this.mssgSelected,
//     required this.mssgIdSelected,
//     required this.mssgCopySelected,
//     required this.onReply,
//     required this.onLongPress,
//     required this.onTapSelect,
//   });

//   final List<dynamic> messages;
//   final String? profileId;
//   final bool mssgSelected;
// Set<String> mssgIdSelected = {};
// Set<String> mssgCopySelected = {};
//   // final List<String> ;
//   final Function(dynamic msg) onReply;
//   final Function(dynamic msg) onLongPress;
//   final Function(dynamic msg) onTapSelect;

//   @override
//   Widget build(BuildContext context) {
//     if (messages.isEmpty) return const SizedBox();

//     return ListView.builder(
//       reverse: true,
//       itemCount: messages.length,
//       itemBuilder: (context, index) {
//         final msg = messages[messages.length - index - 1];

//         final bool isMe =
//             msg.senderId.toString() == profileId?.toString();

//         return Dismissible(
//           key: Key(msg.id.toString()),
//           direction: DismissDirection.startToEnd,
//           confirmDismiss: (_) async {
//             onReply(msg);
//             return false;
//           },
//           background: Container(
//             alignment: Alignment.centerLeft,
//             padding: const EdgeInsets.only(left: 20),
//             child: const Icon(Icons.reply, color: Colors.blue),
//           ),
//           child: GestureDetector(
//             onLongPress: () => onLongPress(msg),
//             onTap: () => onTapSelect(msg),
//             child: Row(
//               children: [
//                 if (mssgSelected)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8),
//                     child: Icon(
//                       mssgIdSelected.contains(msg.id.toString())
//                           ? Icons.check_circle
//                           : Icons.radio_button_unchecked,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 Expanded(
//                   child: MssgWidgets(
//                     chatStatus: msg.id == 0
//                         ? ChatStatus.sending
//                         : ChatStatus.send,
//                     isMe: isMe,
//                     message: msg.message,
//                     replyMessage: msg.reply?.message,
//                     time: msg.createdAt,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }