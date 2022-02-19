import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

extension DismissibleContextExt on BuildContext {
  Future pushTransparentRoute(
    Widget page, {
    final Duration transitionDuration = const Duration(milliseconds: 250),
    final Duration reverseTransitionDuration =
        const Duration(milliseconds: 250),
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
