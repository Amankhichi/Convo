import 'package:convo/core/model/stroy_model.dart';
import 'package:convo/features/home/presentation/pages/add_stroy_page.dart';
import 'package:convo/features/home/presentation/pages/viwe_stroy_page.dart';
import 'package:flutter/material.dart';
import 'package:convo/core/const.dart/app_colors.dart';

class MyStoryWidget extends StatefulWidget {
  final StoryModel story;
  final List<StoryModel> stories;
  final int index;

  const MyStoryWidget({
    super.key,
    required this.story,
    required this.stories,
    required this.index,
  });

  @override
  State<MyStoryWidget> createState() => _MyStoryWidgetState();
}

class _MyStoryWidgetState extends State<MyStoryWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
  if (widget.story.isMyStory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddStoryPage(),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewStoryPage(
          stories: widget.stories,
          initialIndex: widget.index,
        ),
      ),
    );
  }
},
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              height: 65,
              width: 65,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.story.isMyStory
                      ? Colors.grey
                      : Colors.green,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage:
                    widget.story.imageUrl.isNotEmpty
                        ? NetworkImage(widget.story.imageUrl)
                        : null,
                child: widget.story.imageUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.story.isMyStory
                  ? "Your Story"
                  : widget.story.username,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}