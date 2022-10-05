import 'package:example/demo/models/models.dart';
import 'package:example/demo/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

class StoryPage extends StatelessWidget {
  final StoryModel story;
  final VoidCallback nextGroup;
  final VoidCallback previousGroup;

  const StoryPage({
    required this.story,
    required this.nextGroup,
    required this.previousGroup,
  });

  @override
  Widget build(BuildContext context) {
    void _onTap(TapUpDetails details) async {
      final dx = details.globalPosition.dx;
      final width = MediaQuery.of(context).size.width;
      if (dx < width / 2) return previousGroup();
      return nextGroup();
    }

    return GestureDetector(
      onTapUp: _onTap,
      child: StoryImage(story, isFullScreen: true),
    );
  }
}
