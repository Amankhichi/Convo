import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          /// IMAGE
          Center(
            child: Hero(
              tag: "profile-image",

              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,

                child: Image.network(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          /// BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),

              child: CircleAvatar(
                backgroundColor: Colors.black54,

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}