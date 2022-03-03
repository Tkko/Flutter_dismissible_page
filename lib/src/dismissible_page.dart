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

part 'dismissible_page_drag_update_details.dart';

const double _kDismissThreshold = 0.15;

class DismissiblePage extends StatelessWidget {
  const DismissiblePage({
    required this.child,
    required this.onDismissed,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.isFullScreen = true,
    this.disabled = false,
    this.backgroundColor = Colors.black,
    this.direction = DismissiblePageDismissDirection.vertical,
    this.dismissThresholds = const <DismissiblePageDismissDirection, double>{},
    this.dragStartBehavior = DragStartBehavior.down,
    this.dragSensitivity = 0.7,
    this.minRadius = 7,
    this.minScale = .85,
    this.maxRadius = 30,
    this.maxTransformValue = .4,
    this.startingOpacity = 1,
    this.behavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    Key? key,
  }) : super(key: key);

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Called when the user starts dragging the widget.
  final VoidCallback? onDragStart;

  /// Called when the user ends dragging the widget.
  final VoidCallback? onDragEnd;

  /// Called when the widget has been dragged. [0.0 - 1.0]
  final ValueChanged<double>? onDragUpdate;

  /// If true widget will ignore device padding
  /// [MediaQuery.of(context).padding]
  final bool isFullScreen;

  /// The minimum amount of scale widget can have while dragging
  /// Note that scale decreases as user drags
  final double minScale;

  /// The minimum amount fo border radius widget can have
  final double minRadius;

  /// The maximum amount of border radius widget can have while dragging
  /// Note that radius increases as user drags
  final double maxRadius;

  /// The amount of distance widget is able to drag. value [0.0 - 1.0]
  final double maxTransformValue;

  /// If true the widget will ignore gestures
  final bool disabled;

  /// Widget that should be dismissed
  final Widget child;

  /// Background color of [DismissiblePage]
  final Color backgroundColor;

  /// The amount of opacity [backgroundColor] will have when start dragging the widget.
  final double startingOpacity;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed. default is [_kDismissThreshold], value [0.0 - 1.0]
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;

  /// Represents how much responsive dragging the widget will be
  /// Doesn't work on [DismissiblePageDismissDirection.multi]
  final double dragSensitivity;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// The amount of time the widget will spend returning to initial position if widget is not dismissed after drag
  final Duration reverseDuration;

  /// How to behave during hit tests.
  ///
  /// This defaults to [HitTestBehavior.opaque].
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    if (direction == DismissiblePageDismissDirection.multi) {
      return MultiAxisDismissiblePage(
        onDismissed: onDismissed,
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
        onDragUpdate: onDragUpdate,
        reverseDuration: reverseDuration,
        behavior: behavior,
        child: child,
      );
    }
    return SingleAxisDismissiblePage(
      onDismissed: onDismissed,
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
      onDragUpdate: onDragUpdate,
      reverseDuration: reverseDuration,
      behavior: behavior,
      child: child,
    );
  }
}
