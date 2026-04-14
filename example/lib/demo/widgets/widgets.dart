import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/demo/models/models.dart';
import 'package:example/demo/pages/stories_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({required this.story, required this.pageModel, super.key});

  final StoryModel story;
  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushTransparentRoute<void>(
          StoriesWrapper(
            parentIndex: pageModel.stories.indexOf(story),
            pageModel: pageModel,
          ),
          transitionDuration: pageModel.transitionDuration,
          reverseTransitionDuration: pageModel.reverseTransitionDuration,
        );
      },
      child: StoryImage(story),
    );
  }
}

class StoryImage extends StatefulWidget {
  const StoryImage(
    this.story, {
    super.key,
    this.isFullScreen = false,
    this.withSafeArea = false,
  });

  final StoryModel story;
  final bool isFullScreen;
  final bool withSafeArea;

  @override
  State<StoryImage> createState() => StoryImageState();
}

class StoryImageState extends State<StoryImage> {
  late String imageUrl;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.story.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.story.storyId,
      placeholderBuilder: (_, size, child) => child,
      child: Material(
        child: Container(
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(widget.isFullScreen ? 20 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 8),
            color: const Color.fromRGBO(237, 241, 248, 1),
            image: DecorationImage(
              onError: (_, _) {
                setState(() {
                  imageUrl = widget.story.altUrl;
                  hasError = true;
                });
              },
              fit: BoxFit.cover,
              image: hasError
                  ? AssetImage(widget.story.altUrl)
                  : NetworkImage(imageUrl) as ImageProvider,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: widget.withSafeArea
                  ? MediaQuery.paddingOf(context).bottom
                  : 0,
            ),
            child: Text(
              widget.story.title,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class DurationSlider extends StatelessWidget {
  const DurationSlider({
    required this.title,
    required this.duration,
    required this.onChanged,
    super.key,
  });
  final String title;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$title - ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${duration.inMilliseconds}ms',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
        Slider(
          value: duration.inMilliseconds.toDouble(),
          max: 1000,
          divisions: 20,
          label: duration.inMilliseconds.toString(),
          onChanged: (value) {
            onChanged.call(Duration(milliseconds: value.round()));
          },
        ),
      ],
    );
  }
}
