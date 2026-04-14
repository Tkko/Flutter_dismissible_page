import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/demo/models/models.dart';
import 'package:flutter/material.dart';

class ScrollablePage extends StatefulWidget {
  const ScrollablePage(this.story, {super.key});

  final StoryModel story;

  @override
  State<ScrollablePage> createState() => _ScrollablePageState();
}

class _ScrollablePageState extends State<ScrollablePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final child = SizedBox(
      width: size.width,
      height: size.height,
      child: Material(
        color: Colors.transparent,
        child: Hero(
          tag: widget.story.storyId,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.network(
              widget.story.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    return DismissiblePage(
      isFullScreen: false,
      direction: DismissiblePageDismissDirection.multi,
      interactionMode: DismissiblePageInteractionMode.gesture,
      onDismissed: () {
        Navigator.of(context).pop();
      },
      builder: (context, scrollController) => child,
    );
  }
}
