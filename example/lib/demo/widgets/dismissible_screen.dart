import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';

/// Wraps a whole screen so it can be dismissed like the native "swipe back".
/// It follows the demo-wide settings, so the Properties sheet and the Motion
/// Lab change it too.
///
/// Open it with `context.pushTransparentRoute(DismissibleScreen(child: ...))`.
class DismissibleScreen extends StatelessWidget {
  const DismissibleScreen({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => DismissibleDemo(child: child);
}

/// An app bar back button that leaves with the same motion as a swipe. Place
/// it below a [DismissibleScreen], for example as `AppBar.leading`.
class DismissibleBackButton extends StatelessWidget {
  const DismissibleBackButton({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => DismissiblePage.dismiss(context),
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: color),
    );
  }
}
