import 'dart:io';
import 'package:flutter/material.dart';
import 'package:convo/core/model/stroy_model.dart';

class ViewImagePage extends StatefulWidget {
  final String imagePath;

  const ViewImagePage({super.key, required this.imagePath});

  @override
  State<ViewImagePage> createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  bool showTextField = false;
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🖼 Full Image
          Positioned.fill(
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),

          /// 🔝 Top Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Close
                _icon(Icons.close, () => Navigator.pop(context)),

                /// Right Side Edit Options
                Row(
                  children: [
                    _icon(Icons.crop, () {
                      // TODO: Add crop feature
                    }),
                    const SizedBox(width: 10),
                    _icon(Icons.brush, () {
                      // TODO: Add draw feature
                    }),
                    const SizedBox(width: 10),
                    _icon(Icons.text_fields, () {
                      setState(() {
                        showTextField = true;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),

          /// ✍ Text Input
          if (showTextField)
            Center(
              child: TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white, fontSize: 28),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type something...",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),

          /// 🔻 Bottom Story Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  StoryModel(
                    username: "You",
                    imageUrl: widget.imagePath,
                    isMyStory: true,
                  ),
                );
              },
              child: const Text(
                "Your Story",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
