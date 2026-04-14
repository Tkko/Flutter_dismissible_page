import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/demo/models/models.dart';
import 'package:example/demo/pages/story_page.dart';
import 'package:example/demo/widgets/cubic_page_view.dart';
import 'package:flutter/material.dart';

class StoriesWrapper extends StatefulWidget {
  const StoriesWrapper({
    required this.parentIndex,
    required this.pageModel,
    super.key,
  });

  final int parentIndex;
  final DismissiblePageModel pageModel;

  @override
  State<StoriesWrapper> createState() => _StoriesWrapperState();
}

class _StoriesWrapperState extends State<StoriesWrapper>
    with TickerProviderStateMixin {
  late int dWidth;
  late PageController pageCtrl;

  List<StoryModel> get stories => widget.pageModel.stories;

  bool get isLastPage => stories.length == pageCtrl.page!.round() + 1;

  @override
  void initState() {
    pageCtrl = PageController(initialPage: widget.parentIndex);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    dWidth = MediaQuery.widthOf(context).floor();
    super.didChangeDependencies();
  }

  void nextPage() {
    if (isLastPage) {
      Navigator.maybePop(context);
      return;
    }
    next();
  }

  void previousPage() {
    if (pageCtrl.page!.round() == 0) {
      Navigator.maybePop(context);
      return;
    }
    previous();
  }

  void next() {
    pageCtrl.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  void previous() {
    pageCtrl.previousPage(
      duration: const Duration(milliseconds: 200),
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
      onDismissed: () => Navigator.of(context).maybePop(),
      interactionMode: DismissiblePageInteractionMode.gesture,
      isFullScreen: widget.pageModel.isFullScreen,
      minRadius: widget.pageModel.minRadius,
      maxRadius: widget.pageModel.maxRadius,
      dragSensitivity: widget.pageModel.dragSensitivity,
      maxTransformValue: widget.pageModel.maxTransformValue,
      direction: widget.pageModel.direction,
      disabled: widget.pageModel.disabled,
      backgroundColor: widget.pageModel.backgroundColor,
      dismissThresholds: widget.pageModel.dismissThresholds,
      dragStartBehavior: widget.pageModel.dragStartBehavior,
      minScale: widget.pageModel.minScale,
      startingOpacity: widget.pageModel.startingOpacity,
      hitTestBehavior: widget.pageModel.behavior,
      reverseDuration: widget.pageModel.reverseDuration,
      builder: (context, _) => CubicPageView(
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
