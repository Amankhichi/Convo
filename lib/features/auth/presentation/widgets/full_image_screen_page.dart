import 'package:flutter/material.dart';

class FullScreenImagePage extends StatefulWidget {
  const FullScreenImagePage({super.key, required this.image});

  final String image;

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  double _dragOffset = 0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > 120) {
      Navigator.pop(context);
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          /// BACKGROUND
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: Colors.black.withOpacity(
              (1 - (_dragOffset.abs() / 500)).clamp(0.4, 1.0),
            ),
          ),

          /// IMAGE (IMPORTANT FIX HERE)
          Center(
            child: Transform.translate(
              offset: Offset(0, _dragOffset),

              /// 👇 ONLY THIS WIDGET HANDLES ZOOM
              child: Hero(
                tag: widget.image,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 5,

                  /// 🔥 THIS FIXES ZOOM NOT WORKING ISSUE
                  clipBehavior: Clip.none,

                  child: Image.network(
                    widget.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          /// TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          /// SWIPE DETECTOR (ONLY OUTSIDE IMAGE AREA)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
            ),
          ),
        ],
      ),
    );
  }
}