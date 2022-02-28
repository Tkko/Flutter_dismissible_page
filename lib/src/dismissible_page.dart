import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'dismissible_extensions.dart';

part 'dismissible_routes.dart';

part 'multi_axis_dismissible_page.dart';

part 'dismissible_page_dismiss_direction.dart';

part 'single_axis_dismissible_page.dart';

const double _kDismissThreshold = 0.15;

class DismissiblePage extends StatelessWidget {
  const DismissiblePage({
    required this.onDismiss,
    required this.child,
    this.isFullScreen = true,
    this.disabled = false,
    this.backgroundColor = Colors.black,
    this.direction = DismissiblePageDismissDirection.vertical,
    this.dismissThresholds = const <DismissiblePageDismissDirection, double>{},
    this.dragStartBehavior = DragStartBehavior.down,
    this.crossAxisEndOffset = 0.0,
    this.dragSensitivity = 0.7,
    this.minRadius = 7,
    this.minScale = .85,
    this.maxRadius = 30,
    this.maxTransformValue = .4,
    this.startingOpacity = 1,
    this.onDragStart,
    this.onDragEnd,
    this.behavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    Key? key,
  }) : super(key: key);

  final double startingOpacity;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final VoidCallback onDismiss;
  final bool isFullScreen;
  final double minScale;
  final double minRadius;
  final double maxRadius;
  final double maxTransformValue;
  final bool disabled;
  final Widget child;
  final Color backgroundColor;
  final DismissiblePageDismissDirection direction;
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;
  final double crossAxisEndOffset;
  final double dragSensitivity;
  final DragStartBehavior dragStartBehavior;
  final Duration reverseDuration;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    if (direction == DismissiblePageDismissDirection.multi) {
      return MultiAxisDismissiblePage(
        onDismiss: onDismiss,
        isFullScreen: isFullScreen,
        disabled: disabled,
        backgroundColor: backgroundColor,
        direction: direction,
        dismissThresholds: dismissThresholds,
        dragStartBehavior: dragStartBehavior,
        dragSensitivity: dragSensitivity,
        minRadius: minRadius,
        minScale: minScale,
        maxRadius: maxRadius,
        maxTransformValue: maxTransformValue,
        startingOpacity: startingOpacity,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        reverseDuration: reverseDuration,
        behavior: behavior,
        child: child,
      );
    }

    return SingleAxisDismissiblePage(
      onDismiss: onDismiss,
      isFullScreen: isFullScreen,
      disabled: disabled,
      backgroundColor: backgroundColor,
      direction: direction,
      dismissThresholds: dismissThresholds,
      dragStartBehavior: dragStartBehavior,
      dragSensitivity: dragSensitivity,
      minRadius: minRadius,
      minScale: minScale,
      maxRadius: maxRadius,
      maxTransformValue: maxTransformValue,
      startingOpacity: startingOpacity,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      reverseDuration: reverseDuration,
      behavior: behavior,
      child: child,
    );
  }
}
