part of 'dismissible_page.dart';

const _transitionDuration = Duration(milliseconds: 250);

/// BuildContext Helper methods
extension DismissibleContextExt on BuildContext {
  /// Navigates to desired page with transparent transition background
  Future<T?> pushTransparentRoute<T>(
    Widget page, {
    Color backgroundColor = Colors.transparent,
    Duration transitionDuration = _transitionDuration,
    Duration reverseTransitionDuration = _transitionDuration,
    bool rootNavigator = false,
  }) {
    return Navigator.of(this, rootNavigator: rootNavigator).push(
      TransparentRoute(
        builder: (_) => page,
        backgroundColor: backgroundColor,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
      ),
    );
  }
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
