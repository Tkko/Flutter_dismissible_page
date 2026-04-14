import 'package:example/demo/models/models.dart';
import 'package:example/demo/widgets/widgets.dart';
import 'package:flutter/material.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({
    required this.story,
    required this.nextGroup,
    required this.previousGroup,
    super.key,
  });

  final StoryModel story;
  final VoidCallback nextGroup;
  final VoidCallback previousGroup;

  @override
  Widget build(BuildContext context) {
    Future<void> onTap(TapUpDetails details) async {
      final dx = details.globalPosition.dx;
      final width = MediaQuery.widthOf(context);
      if (dx < width / 2) return previousGroup();
      return nextGroup();
    }

    return GestureDetector(
      onTapUp: onTap,
      child: StoryImage(story, isFullScreen: true, withSafeArea: true),
    );
  }
}
