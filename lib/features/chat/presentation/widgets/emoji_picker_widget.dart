// import 'package:flutter/material.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

// class EmojiPickerWidget extends StatelessWidget {
//   final bool isVisible;
//   final TextEditingController controller;

//   const EmojiPickerWidget({
//     super.key,
//     required this.isVisible,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     /// Hide when keyboard is open
//     if (!isVisible || MediaQuery.of(context).viewInsets.bottom != 0) {
//       return const SizedBox.shrink();
//     }

//     return AnimatedSlide(
//       duration: const Duration(milliseconds: 250),
//       offset: isVisible ? Offset.zero : const Offset(0, 1),
//       child: SizedBox(
//         height: MediaQuery.of(context).size.height * 0.35,
//         child: EmojiPicker(
//           textEditingController: controller,
//           config: const Config(
//             categoryViewConfig: CategoryViewConfig(
//               initCategory: Category.SMILEYS,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }