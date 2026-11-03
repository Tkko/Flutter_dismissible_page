import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:flutter/widgets.dart';

/// Makes one [DismissiblePageModel] available to every screen of the demo,
/// including those pushed on top of the home page, so the Properties sheet
/// and the Motion Lab change how all of them behave.
class DemoSettings extends InheritedWidget {
  const DemoSettings({required this.model, required super.child, super.key});

  final DismissiblePageModel model;

  // Used when a screen is shown without the demo shell, for example in tests.
  static final _fallback = DismissiblePageModel();

  static DismissiblePageModel of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DemoSettings>()?.model ?? _fallback;

  @override
  bool updateShouldNotify(DemoSettings oldWidget) => model != oldWidget.model;
}
