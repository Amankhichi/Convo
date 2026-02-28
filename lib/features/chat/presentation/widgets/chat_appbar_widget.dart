// import 'package:convo/core/const.dart/app_colors.dart';
// import 'package:convo/core/const.dart/slide_page_route.dart';
// import 'package:convo/features/auth/presentation/bloc/bloc/login_bloc.dart';
// import 'package:convo/features/chat/presentation/pages/contact_user_profile_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:lottie/lottie.dart';

// class ChatAppbarWidget extends StatefulWidget implements PreferredSizeWidget {
//   final bool mssgSelected;
//   final Set<String> mssgIdSelected;
//   final Set<String> mssgCopySelected;
//   final VoidCallback onBack;
//   final VoidCallback onClearSelection;
//   final Function(String id, String message) onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onVoiceCall;
//   final VoidCallback onVideoCall;
//   final dynamic user;
//   final dynamic state;

//   const ChatAppbarWidget({
//     super.key,
//     required this.mssgSelected,
//     required this.mssgIdSelected,
//     required this.mssgCopySelected,
//     required this.onBack,
//     required this.onClearSelection,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onVoiceCall,
//     required this.onVideoCall,
//     required this.user,
//     required this.state,
//   });

//   @override
//   State<ChatAppbarWidget> createState() => _ChatAppbarWidgetState();

//   // ✅ Fix UnimplementedError
//   @override
//   Size get preferredSize => const Size.fromHeight(70);
// }

// class _ChatAppbarWidgetState extends State<ChatAppbarWidget> {
//   // ✅ ADD THIS
//   @override
//   // Size get preferredSize => const Size.fromHeight(70);
//   // bool mssgEdit = false;
//   // String? editingMessageId;

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       toolbarHeight: 70,
//       backgroundColor: AppColors.ChatprofileColor(context),
//       leading: IconButton(
//         icon: Icon(
//           widget.mssgSelected ? Icons.close : Icons.arrow_back,
//           color: Colors.white,
//         ),
//         onPressed: widget.onBack,
//       ),
//       titleSpacing: 0,
//       title: widget.mssgSelected ? null : _buildUserTile(context),
//       actions: widget.mssgSelected
//           ? _buildSelectionActions(context)
//           : _buildNormalActions(),
//     );
//   }

//   Widget _buildUserTile(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       onTap: () {
//         Navigator.push(
//           context,
//           SlidePageRoute(
//             page: ContactUserProfilePage(user: widget.user),
//             beginOffset: const Offset(-1, 0),
//           ),
//         );
//       },
//       leading: CircleAvatar(
//         radius: 25,
//         backgroundColor: AppColors.primary,
//         child: ClipOval(
//           child: Lottie.asset(widget.user.lotti, fit: BoxFit.cover),
//         ),
//       ),
//       title: Text(
//         widget.user.name,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//         ),
//       ),
//       subtitle: Text(
//         widget.user.online ? "online" : "offline",
//         style: TextStyle(
//           color: widget.user.online ? Colors.green : Colors.white,
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildSelectionActions(BuildContext context) {
//     return [
//       if (widget.mssgIdSelected.length == 1)
//         Builder(
//           builder: (_) {
//             final profile = context.read<LoginBloc>().state.profile;

//             final selectedMsg = widget.state.messages.firstWhere(
//               (e) => e.id.toString() == widget.mssgIdSelected.first,
//             );

//             if (selectedMsg.senderId.toString() != profile?.id.toString()) {
//               return const SizedBox();
//             }

//             return IconButton(
//               icon: const Icon(Icons.edit, color: Colors.white),
//               onPressed: () {
//                 // Call the callback to edit
//                 widget.onEdit(
//                   widget.mssgIdSelected.first, // message id
//                   selectedMsg.message, // message text
//                 );

//                 // Clear selection after clicking edit
//                 widget.onClearSelection();
//               },
//             );
//           },
//         ),

//       IconButton(
//         icon: const Icon(Icons.copy, color: Colors.white),
//         onPressed: () async {
//           if (widget.mssgCopySelected.isEmpty) return;

//           final copyText = widget.mssgCopySelected.join("\n");

//           await Clipboard.setData(ClipboardData(text: copyText));

//           Fluttertoast.showToast(
//             msg: "Text Copied",
//             gravity: ToastGravity.CENTER,
//           );

//           widget.onClearSelection();
//         },
//       ),

//       IconButton(
//         icon: const Icon(Icons.delete, color: Colors.white),
//         onPressed: widget.onDelete,
//       ),
//     ];
//   }

//   List<Widget> _buildNormalActions() {
//     return [
//       IconButton(
//         onPressed: widget.onVoiceCall,
//         icon: const Icon(Icons.call, color: Colors.white, size: 28),
//       ),
//       IconButton(
//         onPressed: widget.onVideoCall,
//         icon: const Icon(Icons.videocam, color: Colors.white, size: 28),
//       ),
//       IconButton(
//         onPressed: () {},
//         icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
//       ),

//       const SizedBox(width: 8),
//     ];
//   }
// }
