import 'package:convo/core/const.dart/app_colors.dart';
import 'package:convo/core/model/stroy_model.dart';
import 'package:convo/features/home/presentation/pages/viwe_stroy_page.dart';
import 'package:flutter/material.dart';

class MyStoryWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewStoryPage(
              stories: stories,
              initialIndex: index,
            ),
          ),
        );
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
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: story.imageUrl.isNotEmpty
                    ? NetworkImage(story.imageUrl)
                    : null,
                child: story.imageUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              story.username,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}