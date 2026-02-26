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
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void closeStory() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 12) {
            closeStory(); // Swipe Down
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final story = widget.stories[index];

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    story.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 50,
                  left: 20,
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18),
                      const SizedBox(width: 10),
                      Text(
                        story.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}