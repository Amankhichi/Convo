import 'package:convo/core/model/stroy_model.dart';
import 'package:flutter/material.dart';

class ViewStoryPage extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const ViewStoryPage({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<ViewStoryPage> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends State<ViewStoryPage> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  void next() {
    if (currentIndex < widget.stories.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void previous() {
    if (currentIndex > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;

          if (details.globalPosition.dx < width / 2) {
            previous();
          } else {
            next();
          }
        },
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];

                return Image.network(
                  story.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),

            /// 🔥 Top Overlay
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 18),
                      const SizedBox(width: 10),
                      Text(
                        widget.stories[currentIndex].username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}