import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/story_page.dart';
import 'package:dismissible_page_example/demo/widgets/cubic_page_view.dart';
import 'package:flutter/material.dart';

class StoriesWrapper extends StatefulWidget {
  final int parentIndex;
  final DismissiblePageModel pageModel;

  StoriesWrapper({
    required this.parentIndex,
    required this.pageModel,
  });

  @override
  _StoriesWrapperState createState() => _StoriesWrapperState();
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
      onDismissed: () => Navigator.of(context).pop(),
      isFullScreen: widget.pageModel.isFullScreen,
      borderRadius: widget.pageModel.borderRadius,
      dragSensitivity: widget.pageModel.dragSensitivity,
      maxTransformValue: widget.pageModel.maxTransformValue,
      direction: widget.pageModel.direction,
      enabled: widget.pageModel.enabled,
      background: widget.pageModel.background,
      dismissThresholds: widget.pageModel.dismissThresholds,
      dragStartBehavior: widget.pageModel.dragStartBehavior,
      minScale: widget.pageModel.minScale,
      hitTestBehavior: widget.pageModel.behavior,
      reverseDuration: widget.pageModel.reverseDuration,
      onDragUpdate: (d) => print(d.offset.dy),
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
