part of '../dismissible_page.dart';

class TransparentRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  TransparentRoute({
    required this.builder,
    this.backgroundColor = Colors.transparent,
    this.transitionDuration = _transitionDuration,
    this.reverseTransitionDuration = _transitionDuration,
    this.title,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog = true,
  });

  final WidgetBuilder builder;

  @override
  final String? title;

  /// Builds the primary contents of the route.
  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  final Color backgroundColor;

  @override
  Color get barrierColor => backgroundColor;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;

  @override
  Widget buildTransitions(_, Animation<double> animation, __, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
