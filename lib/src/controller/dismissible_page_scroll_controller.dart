part of '../dismissible_page.dart';

// Scroll offsets follow the axis direction; page offsets follow screen coordinates.
double _physicalScrollDelta(double delta, AxisDirection direction) =>
    axisDirectionIsReversed(direction) ? -delta : delta;

/// A [ScrollController] that seamlessly bridges a scrollable widget
/// ([ListView], [CustomScrollView], [GridView], etc.) with a [DismissiblePage].
///
/// Automatically coordinates with [BouncingScrollPhysics] (iOS) and
/// [ClampingScrollPhysics] (Android) to preserve authentic scroll friction,
/// velocity, and spring simulations while enabling drag-to-dismiss.
class DismissiblePageScrollController extends ScrollController {
  DismissiblePageScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  _DismissibleArbiter? _arbiter;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _DismissiblePageScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      getArbiter: () => _arbiter,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    );
  }
}

class _DismissiblePageScrollPosition extends ScrollPositionWithSingleContext {
  _DismissiblePageScrollPosition({
    required super.physics,
    required super.context,
    required this.getArbiter,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  final _DismissibleArbiter? Function() getArbiter;

  _DismissibleArbiter? get _arbiter => getArbiter();

  bool _isDismissDragging = false;

  @override
  void applyUserOffset(double delta) {
    final arbiter = _arbiter;
    if (arbiter == null ||
        arbiter.direction == DismissiblePageDismissDirection.none) {
      super.applyUserOffset(delta);
      return;
    }

    final isVertical = axis == Axis.vertical;
    final currentCoord = _physicalScrollDelta(
      isVertical ? arbiter.offset.dy : arbiter.offset.dx,
      axisDirection,
    );
    final sensitivity = arbiter.dragSensitivity;

    // 1. If page is currently offset away from origin:
    // Any reverse drag must return the page to origin first (Fixes Issue #36)
    if (currentCoord != 0) {
      final isReversing =
          (currentCoord > 0 && delta < 0) || (currentCoord < 0 && delta > 0);
      if (isReversing) {
        final neededDelta = -currentCoord / sensitivity;
        if (delta.abs() >= neededDelta.abs()) {
          // Reached or crossed origin: reset coordinate to 0 and pass leftover to list!
          final leftover = delta - neededDelta;
          arbiter.setOffset(
            isVertical
                ? Offset(arbiter.offset.dx, 0)
                : Offset(0, arbiter.offset.dy),
          );
          // The page is home again; the rest of the gesture belongs to the list.
          _isDismissDragging = false;
          arbiter.endDrag();
          if (leftover != 0.0) {
            super.applyUserOffset(leftover);
          }
          return;
        }
      }

      // Absorb into page drag. This also covers re-grabbing a page that is
      // still rebounding, which must be released through [goBallistic] too.
      if (!_isDismissDragging) {
        _isDismissDragging = true;
        arbiter.startDrag();
      }
      final physicalDelta = _physicalScrollDelta(delta, axisDirection);
      final offsetDelta =
          isVertical ? Offset(0, physicalDelta) : Offset(physicalDelta, 0);
      arbiter.applyDelta(offsetDelta);
      return;
    }

    // 2. At edges (top or bottom):
    final atStart = pixels <= minScrollExtent;
    final atEnd = pixels >= maxScrollExtent;

    if ((delta > 0 && atStart) || (delta < 0 && atEnd)) {
      final physicalDelta = _physicalScrollDelta(delta, axisDirection);
      final offsetDelta =
          isVertical ? Offset(0, physicalDelta) : Offset(physicalDelta, 0);
      if (arbiter.isDeltaAllowed(offsetDelta)) {
        if (!_isDismissDragging) {
          _isDismissDragging = true;
          arbiter.startDrag();
        }
        arbiter.applyDelta(offsetDelta);
        return;
      }
    }

    super.applyUserOffset(delta);
  }

  @override
  void goBallistic(double velocity) {
    final wasDismissDragging = _isDismissDragging;
    _isDismissDragging = false;
    final arbiter = _arbiter;
    if (wasDismissDragging && arbiter != null && arbiter.isDragging) {
      arbiter.endDrag(
        velocity: _physicalScrollDelta(-velocity, axisDirection),
      );
      beginActivity(IdleScrollActivity(this));
      return;
    }

    super.goBallistic(velocity);
  }

  @override
  void dispose() {
    if (_isDismissDragging) {
      _isDismissDragging = false;
      _arbiter?.cancelDrag();
    }
    super.dispose();
  }
}
