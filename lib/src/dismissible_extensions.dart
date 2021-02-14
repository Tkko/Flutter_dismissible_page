import 'package:flutter/material.dart';
import '../dismissible_page.dart';

extension DismissibleContextExt on BuildContext {
  Future pushTransparentRoute(Widget page) => Navigator.of(this).push(
        TransparentRoute(
          backgroundColor: Colors.black.withOpacity(0.35),
          builder: (_) => page,
        ),
      );
}
