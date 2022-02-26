import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/models.dart';
import 'package:example/pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          transitionDuration: story.transitionDuration!,
          reverseTransitionDuration: story.reverseTransitionDuration!,
        );
      },
      child: StoryImage(story),
    );
  }
}

class StoryImage extends StatefulWidget {
  final StoryModel story;
  final bool isFullScreen;

  StoryImage(this.story, {this.isFullScreen = false});

  @override
  _StoryImageState createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.story.imageUrl ?? widget.story.altUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.story.storyId,
      child: Material(
        color: Colors.transparent,
        child: Container(
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(widget.isFullScreen ? 20 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 8),
            color: Color.fromRGBO(237, 241, 248, 1),
            image: DecorationImage(
              onError: (_, __) {
                setState(() => imageUrl = widget.story.altUrl);
              },
              fit: BoxFit.cover,
              image: NetworkImage(imageUrl),
            ),
          ),
          child: Text(
            widget.story.title,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
