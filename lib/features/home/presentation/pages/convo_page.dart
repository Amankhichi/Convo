// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:convo/features/home/presentation/widgets/custom_text.dart';

// class ConvoIntroPage extends StatefulWidget {
//   const ConvoIntroPage({super.key});

//   @override
//   State<ConvoIntroPage> createState() => _ConvoIntroPageState();
// }

// class _ConvoIntroPageState extends State<ConvoIntroPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;
//   late Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _scale = Tween<double>(begin: 0.6, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
//     );

//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ScaleTransition(
//                 scale: _scale,
//                 child: SizedBox(
//                   height: 140,
//                   width: 140,
//                   child: Lottie.asset(
//                     'assests/lotti/Personal Character.json', 
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// 🟢 App Name
//               SlideTransition(
//                 position: _slide,
//                 child:  CustomText(
//                   text: "Convo",
//                   size: 28,
//                   bold: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               /// 📝 Description
//               SlideTransition(
//                 position: _slide,
//                 child: CustomText(
//                   text:
//                       "Connect, chat, and share moments instantly with a smooth and secure messaging experience.",
//                   size: 14,
//                   clr: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
