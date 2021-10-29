import 'package:example/_models.dart';
import 'package:example/_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';

class StoryWidget extends StatelessWidget {
  final StoryModel story;
  final List<StoryModel> stories;

  const StoryWidget({required this.story, required this.stories});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushTransparentRoute(
          StoriesWrapper(
            parentIndex: stories.indexOf(story),
            stories: stories,
          ),
        );
      },
      child: Hero(
        tag: story.storyId,
        child: Container(
          padding: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(story.imageUrl!),
            ),
          ),
          child: Text(
            story.title,
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
