part of 'dismissible_page.dart';

const _transitionDuration = Duration(milliseconds: 250);

extension DismissibleContextExt on BuildContext {
  Future pushTransparentRoute(
    Widget page, {
    final Duration transitionDuration = _transitionDuration,
    final Duration reverseTransitionDuration = _transitionDuration,
  }) =>
      Navigator.of(this).push(
        TransparentRoute(
          backgroundColor: Colors.black.withOpacity(0.35),
          builder: (_) => page,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
        ),
      );
}
