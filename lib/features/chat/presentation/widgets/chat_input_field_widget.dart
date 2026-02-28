// import 'package:convo/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:convo/core/const.dart/app_colors.dart';

// class ChatInputFieldWidget extends StatefulWidget {
//   final String receiverId;
//   final bool isEditing;
//   final String? editingMessageId;
//   final int? replyMessageId;
//   final VoidCallback? onCancelEdit;
//   final VoidCallback? onSendSuccess;

//   const ChatInputFieldWidget({
//     super.key,
//     required this.receiverId,
//     this.isEditing = false,
//     this.editingMessageId,
//     this.replyMessageId,
//     this.onCancelEdit,
//     this.onSendSuccess,
//   });

//   @override
//   State<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
// }

// class _ChatInputFieldWidgetState extends State<ChatInputFieldWidget> {
//   final TextEditingController _messageController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   bool emoji = false;

//   @override
//   void initState() {
//     super.initState();
//     _messageController.addListener(() => setState(() {}));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//       decoration: BoxDecoration(
//         color: AppColors.ChatprofileColor(context),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: Row(
//         children: [
//           /// Emoji Button
//           IconButton(
//             iconSize: 30,
//             color: AppColors.background(context),
//             icon: Icon(
//               emoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
//             ),
//             onPressed: () {
//               setState(() => emoji = !emoji);
//               if (emoji) _focusNode.unfocus();
//               else _focusNode.requestFocus();
//             },
//           ),

//           /// Text Field
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               focusNode: _focusNode,
//               minLines: 1,
//               maxLines: 4,
//               onTap: () => setState(() => emoji = false),
//               style: TextStyle(
//                 color: AppColors.invertTextColor(context),
//                 fontWeight: FontWeight.w600,
//               ),
//               decoration: InputDecoration(
//                 hintText: "Type a message...",
//                 filled: true,
//                 fillColor: AppColors.backgroundColor(context),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//             ),
//           ),

//           const SizedBox(width: 8),

//           /// Mic / Send / Edit Button
//         CircleAvatar(
//   backgroundColor: Colors.transparent,
//   child: _messageController.text.isEmpty
//       ? IconButton(
//           iconSize: 30,
//           color: AppColors.background(context),
//           onPressed: () {
//             // Mic logic
//           },
//           icon: const Icon(Icons.mic, size: 28),
//         )
//       : widget.isEditing
//           ? IconButton(
//               iconSize: 30,
//               color: AppColors.background(context),
//               onPressed: _editMessage,
//               icon: const Icon(Icons.check, size: 28),
//             )
//           : IconButton(
//               iconSize: 30,
//               color: AppColors.background(context),
//               onPressed: _sendMessage,
//               icon: const Icon(Icons.send, size: 28),
//             ),
// )
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     context.read<ChatBloc>().add(
//           ChatEvent.sendMssg(
//             mssg: _messageController.text.trim(),
//             receiverId: widget.receiverId,
//             replyTo: widget.replyMessageId,
//           ),
//         );

//     _messageController.clear();
//     widget.onSendSuccess?.call();
//   }

// void _editMessage() {
//   if (widget.editingMessageId == null) return;

//   context.read<ChatBloc>().add(
//     ChatEvent.editMssg(
//       mssgId: int.parse(widget.editingMessageId!),
//       newMssg: _messageController.text.trim(),
//     ),
//   );

//   _messageController.clear();          
//   widget.onCancelEdit?.call();         
// }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
// }