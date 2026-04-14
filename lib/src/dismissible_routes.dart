part of 'dismissible_page.dart';

/// {@template transparent_route}
/// A transparent page route that provides a fade transition and allows
/// the underlying content to show through.
/// 
/// This route is used internally by [DismissiblePage] to create modal
/// presentations with custom background colors and transition effects.
/// The route supports:
/// 
/// - Transparent/semi-transparent backgrounds
/// - Fade in/out transitions
/// - Barrier dismissal
/// - Custom transition durations
/// {@endtemplate}
class TransparentRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  /// {@macro transparent_route}
  TransparentRoute({
    required this.builder,
    required this.backgroundColor,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    this.title,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog = true,
  });

  /// Builder function that creates the widget content for this route.
  final WidgetBuilder builder;

  /// The title of the route, typically used for accessibility and debugging.
  @override
  final String? title;

  /// Whether the route should maintain its state when not visible.
  /// 
  /// When true, the route's state is preserved even when another route
  /// is pushed on top of it.
  @override
  final bool maintainState;

  /// The duration of the forward transition animation.
  @override
  final Duration transitionDuration;

  /// The duration of the reverse transition animation.
  @override
  final Duration reverseTransitionDuration;

  /// The background color of the route's barrier.
  /// 
  /// This color is displayed behind the route content and can be
  /// transparent or semi-transparent to allow underlying content
  /// to show through.
  final Color backgroundColor;

  /// The color of the modal barrier that covers the underlying content.
  @override
  Color get barrierColor => backgroundColor;

  /// Builds the primary contents of the route.
  @override
  Widget buildContent(BuildContext context) => builder(context);

  /// A string description of this route, used for debugging purposes.
  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  /// Whether the route can be dismissed by tapping the barrier.
  @override
  bool get barrierDismissible => true;

  /// Whether this route obscures previous routes when active.
  /// 
  /// Returns false to allow underlying content to remain visible
  /// through transparent areas.
  @override
  bool get opaque => false;

  /// Builds the transition animation for this route.
  /// 
  /// Creates a fade transition that animates the opacity of the
  /// route content from 0.0 to 1.0 during the forward transition
  /// and from 1.0 to 0.0 during the reverse transition.
  @override
  Widget buildTransitions(_, Animation<double> animation, _, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
