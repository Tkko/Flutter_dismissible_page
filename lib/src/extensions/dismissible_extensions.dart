part of '../dismissible_page.dart';

/// BuildContext Helper methods
extension DismissibleContextExt on BuildContext {
  /// Navigates to desired page with transparent transition background
  Future<T?> pushTransparentRoute<T>(
    Widget page, {
    Color backgroundColor = Colors.transparent,
    Duration transitionDuration = _transitionDuration,
    Duration reverseTransitionDuration = _transitionDuration,
    bool rootNavigator = false,
    bool barrierDismissible = true,
    bool opaque = false,
    TransparentRouteTransitionsBuilder transitionBuilder = _fadeTransition,
  }) {
    return Navigator.of(this, rootNavigator: rootNavigator).push(
      TransparentRoute<T>(
        builder: (_) => page,
        backgroundColor: backgroundColor,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        barrierDismissible: barrierDismissible,
        opaque: opaque,
        transitionBuilder: transitionBuilder,
      ),
    );
  }
}
