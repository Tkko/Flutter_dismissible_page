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
part 'models/dismissible_page_side.dart';
part 'routing/dismissible_routes.dart';
part 'widgets/dismissible_page_core.dart';

const double _kDismissThreshold = 0.15;

/// Flutter widget that allows you to dismiss page in any direction,
/// coordinating seamlessly with inner scrollables ([ListView], [CustomScrollView], [PageView], etc.).
class DismissiblePage extends StatelessWidget {
  const DismissiblePage({
    required this.onDismissed,
    required Widget child,
    this.controller,
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
    this.dismissThresholds = const <DismissiblePageSide, double>{},
    this.dragSensitivity = 0.7,
    this.minScale = 0.85,
    this.maxTransformValue = 0.4,
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    super.key,
  })  : assert(dragSensitivity > 0, 'dragSensitivity must be greater than 0'),
        assert(minScale >= 0 && minScale <= 1, 'minScale must be between 0.0 and 1.0'),
        assert(maxTransformValue >= 0 && maxTransformValue <= 1, 'maxTransformValue must be between 0.0 and 1.0'),
        _child = child,
        _builder = null;

  /// Builds content with a controller for explicit scroll coordination.
  const DismissiblePage.builder({
    required this.onDismissed,
    required Widget Function(
      BuildContext context,
      DismissiblePageScrollController controller,
    ) builder,
    this.controller,
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
    this.dismissThresholds = const <DismissiblePageSide, double>{},
    this.dragSensitivity = 0.7,
    this.minScale = 0.85,
    this.maxTransformValue = 0.4,
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    super.key,
  })  : assert(dragSensitivity > 0, 'dragSensitivity must be greater than 0'),
        assert(minScale >= 0 && minScale <= 1, 'minScale must be between 0.0 and 1.0'),
        assert(maxTransformValue >= 0 && maxTransformValue <= 1, 'maxTransformValue must be between 0.0 and 1.0'),
        _child = null,
        _builder = builder;

  /// An optional [DismissiblePageScrollController] for coordinating scrollables.
  final DismissiblePageScrollController? controller;

  /// The content widget, or null when using [DismissiblePage.builder].
  Widget? get child => _child;

  final Widget? _child;

  final Widget Function(
    BuildContext context,
    DismissiblePageScrollController controller,
  )? _builder;

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

  /// Page displacement thresholds (0.0 to 1.0) per destination side.
  ///
  /// Up/down use a fraction of page height; start/end use page width.
  /// Start/end follow [Directionality]. Missing sides default to 0.15.
  /// With [DismissiblePageDismissDirection.all], either axis can dismiss.
  /// These thresholds are independent of [maxTransformValue].
  /// A fast outward fling can dismiss before reaching a distance threshold.
  final Map<DismissiblePageSide, double> dismissThresholds;

  /// Multiplier applied to drag movements.
  final double dragSensitivity;

  /// The scale of the widget at maximum drag.
  final double minScale;

  /// Fraction of page dimension at which visual effects reach their final values.
  ///
  /// Does not limit translation or affect [dismissThresholds].
  final double maxTransformValue;

  /// Duration to animate back to original position when not dismissed.
  final Duration reverseDuration;

  /// How to behave during hit tests.
  final HitTestBehavior hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    assert(
      dismissThresholds.values.every((value) => value >= 0 && value <= 1),
      'Dismiss thresholds must be between 0.0 and 1.0',
    );
    final contentPadding =
        isFullScreen ? EdgeInsets.zero : MediaQuery.paddingOf(context);

    Widget buildContent(
      BuildContext context,
      DismissiblePageScrollController controller,
    ) {
      if (_builder != null) {
        return _builder!(context, controller);
      }
      return child!;
    }

    return _DismissiblePageCore(
      enabled: enabled,
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
