import 'package:flutter/cupertino.dart';

class StoryModel {
  final storyId = UniqueKey();
  final String title;
  final String imageUrl;
  DismissDirection direction;
  Duration? transitionDuration;
  Duration? reverseTransitionDuration;

  StoryModel({
    required this.title,
    required this.imageUrl,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.direction = DismissDirection.down,
  });

  void withParams({
    required DismissDirection direction,
    required Duration transitionDuration,
    required Duration reverseTransitionDuration,
  }) {
    this.direction = direction;
    this.transitionDuration = transitionDuration;
    this.reverseTransitionDuration = reverseTransitionDuration;
  }
}
