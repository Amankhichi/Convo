import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: isNetwork
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.white, size: 64);
                  },
                )
              : Image.file(
                  File(imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.white, size: 64);
                  },
                ),
        ),
      ),
    );
  }
}
