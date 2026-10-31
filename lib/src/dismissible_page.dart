import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'controller/dismissible_page_arbiter.dart';
part 'controller/dismissible_page_scroll_controller.dart';
part 'extensions/dismissible_extensions.dart';
part 'models/dismissible_page_background.dart';
part 'models/dismissible_page_dismiss_direction.dart';
part 'models/dismissible_page_drag_update_details.dart';
part 'models/dismissible_page_radius.dart';
part 'routing/dismissible_routes.dart';
part 'widgets/dismissible_page_core.dart';

const double _kDismissThreshold = 0.15;

/// Flutter widget that allows you to dismiss page in any direction,
/// coordinating seamlessly with inner scrollables ([ListView], [CustomScrollView], [PageView], etc.).
class DismissiblePage extends StatelessWidget {
  const DismissiblePage({
    required this.onDismissed,
    this.controller,
    this.child,
    this.builder,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
    this.isFullScreen = true,
    this.enabled = true,
    this.background = const DismissiblePageBackground.transition(
      from: Colors.black,
      to: Colors.transparent,
    ),
    this.borderRadius = const DismissiblePageRadius.transition(),
    this.direction = DismissiblePageDismissDirection.vertical,
    this.dismissThresholds = const <DismissiblePageDismissDirection, double>{},
    this.dragSensitivity = 0.7,
    this.minScale = 0.85,
    this.maxTransformValue = 0.4,
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    super.key,
  });

  /// An optional [DismissiblePageScrollController] for coordinating scrollables.
  final DismissiblePageScrollController? controller;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// A builder function providing a [DismissiblePageScrollController].
  final Widget Function(
    BuildContext context,
    DismissiblePageScrollController controller,
  )? builder;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Called when dragging starts.
  final VoidCallback? onDragStart;

  /// Called when dragging ends (either settling or dismissed).
  final VoidCallback? onDragEnd;

  /// Called when a drag gesture is cancelled.
  final VoidCallback? onDragCancel;

  /// Called during dragging with progress, offset, radius, scale and opacity details.
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  /// If true, padding from [MediaQuery.paddingOf] is ignored.
  final bool isFullScreen;

  /// Whether dismiss gesture interactions and transitions are enabled.
  final bool enabled;

  /// Configuration for the background scrim behind the dismissing widget.
  final DismissiblePageBackground background;

  /// Configuration for the corner radius applied to the content during drag.
  final DismissiblePageRadius borderRadius;

  /// The direction in which the page can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// Thresholds (0.0 to 1.0) needed to trigger dismissal per direction.
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;

  /// Multiplier applied to drag movements.
  final double dragSensitivity;

  /// The scale of the widget at maximum drag.
  final double minScale;

  /// Fraction of viewport dimension (0.0 to 1.0) representing maximum transform.
  final double maxTransformValue;

  /// Duration to animate back to original position when not dismissed.
  final Duration reverseDuration;

  /// How to behave during hit tests.
  final HitTestBehavior hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    assert(
      child != null || builder != null,
      'Either child or builder must be provided to DismissiblePage',
    );
    final contentPadding =
        isFullScreen ? EdgeInsets.zero : MediaQuery.paddingOf(context);

    Widget buildContent(
      BuildContext context,
      DismissiblePageScrollController controller,
    ) {
      if (builder != null) {
        return builder!(context, controller);
      }
      return child!;
    }

    if (!enabled) {
      final initialColor = background.resolveColor(0);
      final initialRadius = borderRadius.resolveRadius(0);

      var content = child ??
          builder!(
            context,
            controller ?? DismissiblePageScrollController(),
          );
      if (initialRadius > 0) {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(initialRadius),
          child: content,
        );
      }

      Widget body = Padding(
        padding: contentPadding,
        child: content,
      );

      if (initialColor != null) {
        body = ColoredBox(
          color: initialColor,
          child: body,
        );
      }

      return body;
    }

    return _DismissiblePageCore(
      controller: controller,
      onDismissed: onDismissed,
      isFullScreen: isFullScreen,
      background: background,
      borderRadius: borderRadius,
      direction: direction,
      dismissThresholds: dismissThresholds,
      dragSensitivity: dragSensitivity,
      minScale: minScale,
      maxTransformValue: maxTransformValue,
      dragStartBehavior: dragStartBehavior,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      onDragCancel: onDragCancel,
      onDragUpdate: onDragUpdate,
      reverseDuration: reverseDuration,
      hitTestBehavior: hitTestBehavior,
      contentPadding: contentPadding,
      contentBuilder: buildContent,
    );
  }
}
