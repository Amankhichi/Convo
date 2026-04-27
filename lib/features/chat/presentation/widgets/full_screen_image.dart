// import 'package:flutter/material.dart';

// class FullScreenImage extends StatefulWidget {
//   final String imageUrl;
//   final String userName;

//   const FullScreenImage({
//     super.key,
//     required this.imageUrl,
//     required this.userName,
//   });

//   @override
//   State<FullScreenImage> createState() => _FullScreenImageState();
// }

// class _FullScreenImageState extends State<FullScreenImage>
//     with SingleTickerProviderStateMixin {
//   double offsetY = 0;
//   double opacity = 1;

//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   void animateBack() {
//     _animation = Tween(begin: offsetY, end: 0.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     )
//       ..addListener(() {
//         setState(() {
//           offsetY = _animation.value;
//           opacity = 1 - (offsetY.abs() / 300).clamp(0, 1);
//         });
//       });

//     _controller.forward(from: 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onVerticalDragUpdate: (details) {
//         setState(() {
//           offsetY += details.delta.dy;
//           opacity = 1 - (offsetY.abs() / 300).clamp(0, 1);
//         });
//       },
//       onVerticalDragEnd: (details) {
//         if (offsetY.abs() > 150) {
//           Navigator.pop(context);
//         } else {
//           animateBack();
//         }
//       },
//       child: Stack(
//         children: [
//           // Background fade
//           Container(
//             color: Colors.black.withOpacity(opacity),
//           ),

//           // Image
//           Transform.translate(
//             offset: Offset(0, offsetY),
//             child: Center(
//               child: InteractiveViewer(
//                 child: Image.network(
//                   widget.imageUrl,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),

//           // 🔥 AppBar
//           SafeArea(
//             child: Opacity(
//               opacity: opacity,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       widget.userName,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }