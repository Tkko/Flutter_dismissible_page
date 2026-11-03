part of '../dismissible_page.dart';

/// Builds the transition of a [TransparentRoute].
typedef TransparentRouteTransitionsBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    FadeTransition(opacity: animation, child: child);

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
    this.barrierDismissible = true,
    this.opaque = false,
    this.transitionBuilder = _fadeTransition,
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

  /// Whether tapping the barrier pops the route. It has no visible effect
  /// while [backgroundColor] is transparent, but still intercepts the tap.
  @override
  final bool barrierDismissible;

  /// Whether the route obscures the one below it. When false, the route below
  /// stays visible and is not hidden by the transition.
  @override
  final bool opaque;

  /// Builds the enter and exit transition, a fade by default.
  final TransparentRouteTransitionsBuilder transitionBuilder;

  @override
  Color get barrierColor => backgroundColor;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      transitionBuilder(context, animation, secondaryAnimation, child);
}
