part of 'dismissible_page.dart';

const _transitionDuration = Duration(milliseconds: 250);

/// BuildContext Helper methods
extension DismissibleContextExt on BuildContext {
  /// Navigates to desired page with transparent transition background
  Future<T?> pushTransparentRoute<T>(
    Widget page, {
    final Color backgroundColor = Colors.black38,
    final Duration transitionDuration = _transitionDuration,
    final Duration reverseTransitionDuration = _transitionDuration,
    final bool rootNavigator = false,
  }) =>
      Navigator.of(this, rootNavigator: rootNavigator).push(
        TransparentRoute(
          builder: (_) => page,
          backgroundColor: backgroundColor,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
        ),
      );
}

/// GlobalKey Helper methods
extension GlobalKeyExtension on GlobalKey {
  ///
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
