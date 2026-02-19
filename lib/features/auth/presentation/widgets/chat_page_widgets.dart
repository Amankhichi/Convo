// import 'package:convo/core/const.dart/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class ChatTitleWidget extends StatelessWidget {
//   final dynamic user;

//   const ChatTitleWidget({
//     super.key,
//     required this.user,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: CircleAvatar(
//         radius: 25,
//         backgroundColor: AppColors.primary,
//         child: ClipOval(
//           child: Lottie.asset(user.lotti, fit: BoxFit.cover),
//         ),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             user.name,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             user.online ? "online" : "offline",
//             style: TextStyle(
//               fontSize: 13,
//               color: user.online ? Colors.green : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }