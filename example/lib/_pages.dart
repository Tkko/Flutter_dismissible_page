import 'dart:ui';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class StoriesWrapper extends StatefulWidget {
  final int parentIndex;
  final List<StoryModel> stories;

  StoriesWrapper({
    required this.parentIndex,
    required this.stories,
  });

  @override
  _StoriesWrapperState createState() => _StoriesWrapperState();
}

class _StoriesWrapperState extends State<StoriesWrapper>
    with TickerProviderStateMixin {
  late int dWidth;
  late PageController pageCtrl;

  List<StoryModel> get stories => widget.stories;

  bool get isLastPage => stories.length == pageCtrl.page!.round() + 1;

  @override
  void initState() {
    pageCtrl = PageController(initialPage: widget.parentIndex);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    dWidth = MediaQuery.of(context).size.width.floor();
    super.didChangeDependencies();
  }

  void nextPage() {
    if (isLastPage) return Navigator.pop(context);
    next();
  }

  void previousPage() {
    if (pageCtrl.page!.round() == 0) return Navigator.pop(context);
    previous();
  }

  void next() {
    pageCtrl.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  void previous() {
    pageCtrl.previousPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismiss: () => Navigator.of(context).pop(),
      isFullScreen: false,
      minRadius: 16,
      dragSensitivity: .4,
      maxTransformValue: 4,
      direction: stories.first.direction,
      child: CubicPageView(
        controller: pageCtrl,
        children: stories.map((story) {
          return StoryPage(
            story: story,
            nextGroup: nextPage,
            previousGroup: previousPage,
          );
        }).toList(),
      ),
    );
  }
}

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
      child: Hero(
        tag: story.storyId,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(story.imageUrl!),
              ),
            ),
            child: Text(
              story.title,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class CubicPageView extends StatefulWidget {
  final PageController controller;
  final List<Widget> children;

  CubicPageView({
    required this.controller,
    required this.children,
  });

  @override
  _CubicPageViewState createState() => _CubicPageViewState();
}

class _CubicPageViewState extends State<CubicPageView> {
  late PageController _controller;
  late double currentPageValue;

  List<Widget> get children => widget.children;

  @override
  void initState() {
    _controller = widget.controller;
    currentPageValue = _controller.initialPage.toDouble();
    _controller.addListener(() {
      setState(() => currentPageValue = _controller.page!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: children.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, position) {
        Alignment? al;
        if (position == currentPageValue.floor()) al = Alignment.centerRight;
        if (position == currentPageValue.ceil()) al = Alignment.centerLeft;

        if (al != null) {
          return Transform(
            alignment: al,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.003)
              ..rotateY(
                -lerpDouble(0, 50, (position - currentPageValue))! * 3.14 / 180,
              ),
            child: children[position],
          );
        }

        return children[position];
      },
    );
  }
}
