import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

part 'constants.dart';

part 'controller/dismissible_page_arbiter.dart';

part 'controller/dismissible_page_scroll_controller.dart';

part 'extensions/dismissible_extensions.dart';

part 'models/dismissible_page_background.dart';

part 'models/dismissible_page_dismiss_direction.dart';

part 'models/dismissible_page_drag_update_details.dart';

part 'models/dismissible_page_event.dart';

part 'models/dismissible_page_gesture.dart';

part 'models/dismissible_page_handle.dart';

part 'models/dismissible_page_motion.dart';

part 'models/dismissible_page_radius.dart';

part 'models/dismissible_page_side.dart';

part 'models/dismissible_page_transform.dart';

part 'routing/dismissible_routes.dart';

part 'widgets/dismissible_page_core.dart';

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
    this.onDragEvent,
    this.onWillDismiss,
    this.onDismissStart,
    this.isFullScreen = true,
    this.enabled = true,
    this.background = const DismissiblePageBackground.transition(
      from: Colors.black,
      to: Colors.transparent,
    ),
    this.borderRadius = const DismissiblePageRadius.transition(),
    this.direction = DismissiblePageDismissDirection.all,
    this.gesture = const DismissiblePageGesture(),
    this.transform = const DismissiblePageTransform(),
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.motion = const DismissiblePageMotion(),
    this.semanticLabel,
    super.key,
  })  : _child = child,
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
    this.onDragEvent,
    this.onWillDismiss,
    this.onDismissStart,
    this.isFullScreen = true,
    this.enabled = true,
    this.background = const DismissiblePageBackground.transition(
      from: Colors.black,
      to: Colors.transparent,
    ),
    this.borderRadius = const DismissiblePageRadius.transition(),
    this.direction = DismissiblePageDismissDirection.all,
    this.gesture = const DismissiblePageGesture(),
    this.transform = const DismissiblePageTransform(),
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.motion = const DismissiblePageMotion(),
    this.semanticLabel,
    super.key,
  })  : _child = null,
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

  /// Called for every drag lifecycle event: start, update, end and cancel.
  ///
  /// It reports the same moments as [onDragStart], [onDragUpdate], [onDragEnd]
  /// and [onDragCancel] through one callback that can be handled with an
  /// exhaustive `switch` over [DismissiblePageEvent].
  final ValueChanged<DismissiblePageEvent>? onDragEvent;

  /// Asks whether the page may be dismissed, before it leaves.
  ///
  /// Called when a released drag, or [DismissiblePage.dismiss], would dismiss
  /// the page. Returning false (or a future completing with false) keeps the
  /// page, which settles back to its origin. While a future is pending the
  /// page is held where it is and ignores further drags, so a "discard
  /// changes?" dialog can be shown. [onDismissed] only runs when the answer is
  /// true.
  final FutureOr<bool> Function()? onWillDismiss;

  /// Called when the page starts leaving, after [onWillDismiss] allowed it
  /// and right before [onDismissed].
  final VoidCallback? onDismissStart;

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

  /// What counts as a dismissing drag: thresholds, fling speeds, axis lock
  /// and where a drag may start.
  final DismissiblePageGesture gesture;

  /// How a drag translates into movement and visual effects: sensitivity,
  /// minimum scale and the extent of the effects.
  final DismissiblePageTransform transform;

  /// Rebound, exit, dismiss continuation and haptics of released drags.
  final DismissiblePageMotion motion;

  /// A label announced by assistive technologies for the page.
  ///
  /// Whatever the label, a screen reader can dismiss the page with its
  /// dismiss gesture unless [direction] is
  /// [DismissiblePageDismissDirection.none].
  final String? semanticLabel;

  /// How to behave during hit tests.
  final HitTestBehavior hitTestBehavior;

  /// The state and controls of the closest [DismissiblePage] above [context].
  ///
  /// Throws when [context] is not below a [DismissiblePage]; see [maybeOf].
  static DismissiblePageHandle of(BuildContext context) {
    final handle = maybeOf(context);
    assert(
      handle != null,
      'DismissiblePage.of() called with a context that does not contain a '
      'DismissiblePage. Call it from a context built inside the page (for '
      'example with a Builder), not from the widget that creates it.',
    );
    return handle!;
  }

  /// Like [of], but returns null when [context] is not below a
  /// [DismissiblePage].
  static DismissiblePageHandle? maybeOf(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_DismissibleScope>();
    return scope == null ? null : DismissiblePageHandle._(scope.arbiter);
  }

  /// Dismisses the closest [DismissiblePage] above [context] from code.
  ///
  /// The page winds up slightly, then accelerates off-screen towards [side]
  /// while [DismissiblePage.onDismissed] runs, so a close button leaves like a
  /// swipe does instead of only fading. [side] defaults to the side the page's
  /// [DismissiblePage.direction] dismisses towards. Returns false when
  /// [context] is not below a [DismissiblePage], so call it from a context
  /// built inside the page (for example with a [Builder]), not from the widget
  /// that creates the page.
  static bool dismiss(BuildContext context, {DismissiblePageSide? side}) {
    final scope = context.getInheritedWidgetOfExactType<_DismissibleScope>();
    if (scope == null) return false;
    scope.arbiter.dismiss(side: side);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      gesture.dismissThresholds.values
          .every((value) => value >= 0 && value <= 1),
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
      gesture: gesture,
      transform: transform,
      dragStartBehavior: dragStartBehavior,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      onDragCancel: onDragCancel,
      onDragUpdate: onDragUpdate,
      onDragEvent: onDragEvent,
      onWillDismiss: onWillDismiss,
      onDismissStart: onDismissStart,
      semanticLabel: semanticLabel,
      motion: motion,
      hitTestBehavior: hitTestBehavior,
      contentPadding: contentPadding,
      contentBuilder: buildContent,
    );
  }
}
