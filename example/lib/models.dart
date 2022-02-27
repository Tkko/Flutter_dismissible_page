import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';

class StoryModel {
  final String altUrl =
      'https://user-images.githubusercontent.com/26390946/155841439-cba70441-0c45-4a28-806d-9234aa66bea0.png';
  final storyId = UniqueKey();
  final String title;
  final String? imageUrl;
  DismissiblePageDismissDirection direction;
  Duration? transitionDuration;
  Duration? reverseTransitionDuration;

  StoryModel({
    required this.title,
    this.imageUrl,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.direction = DismissiblePageDismissDirection.down,
  });

  void withParams({
    required DismissiblePageDismissDirection direction,
    required Duration transitionDuration,
    required Duration reverseTransitionDuration,
  }) {
    this.direction = direction;
    this.transitionDuration = transitionDuration;
    this.reverseTransitionDuration = reverseTransitionDuration;
  }
}
