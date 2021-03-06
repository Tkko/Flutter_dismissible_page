import 'package:example/_models.dart';
import 'package:example/_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page/dismissible_page.dart';

class StoryWidget extends StatelessWidget {
  final StoryModel story;

  const StoryWidget({this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushTransparentRoute(StoryPage(story: story));
      },
      child: Hero(
        tag: story.storyId,
        child: Container(
          height: 120,
          width: 88,
          padding: const EdgeInsets.all(8),
          child: Text(
            story.title,
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(color: Colors.white),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(story.imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
