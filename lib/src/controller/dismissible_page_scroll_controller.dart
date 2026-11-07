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

  // Where the scrollable was when the finger went down. A pull only dismisses
  // the page when the gesture began at that edge: scrolling quickly to the top
  // and carrying on must not turn into a dismissal. Neither does grabbing the
  // list during a bounce: that drag belongs to the bounce, which would
  // otherwise stay frozen under the moving page.
  bool _dragBeganAtStart = false;
  bool _dragBeganAtEnd = false;

  // Whether this drag began inside the page's drag region. Decided per drag,
  // from where its own finger went down, so other fingers do not matter.
  bool _dragInRegion = true;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _dragInRegion = _arbiter?.isInDragRegion(details.globalPosition) ?? true;
    _dragBeganAtStart =
        !outOfRange && pixels <= minScrollExtent + _kEdgeTolerance;
    _dragBeganAtEnd =
        !outOfRange && pixels >= maxScrollExtent - _kEdgeTolerance;
    return super.drag(details, dragCancelCallback);
  }

  @override
  void applyUserOffset(double delta) {
    final arbiter = _arbiter;
    if (arbiter == null ||
        arbiter.direction == DismissiblePageDismissDirection.none ||
        !_dragInRegion) {
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
      // Touching a displaced page (also one still rebounding) takes it over
      // before anything else, which stops the rebound animation.
      if (!_isDismissDragging) {
        _isDismissDragging = true;
        arbiter.startDrag();
      }
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
            applyUserOffset(leftover);
          }
          return;
        }
      }

      // Absorb into page drag.
      final physicalDelta = _physicalScrollDelta(delta, axisDirection);
      final offsetDelta =
          isVertical ? Offset(0, physicalDelta) : Offset(physicalDelta, 0);
      arbiter.applyDelta(offsetDelta);
      return;
    }

    // 2. At edges (top or bottom):
    // The list scrolls up to the edge and the page takes what is beyond it, so
    // bouncing physics never overscroll underneath a displaced page.
    final isArmed = delta > 0 ? _dragBeganAtStart : _dragBeganAtEnd;
    final toEdge = delta > 0
        ? max(pixels - minScrollExtent, 0.0)
        : min(pixels - maxScrollExtent, 0.0);
    final beyondEdge = delta - toEdge;

    if (isArmed && beyondEdge * delta > 0) {
      final physicalDelta = _physicalScrollDelta(beyondEdge, axisDirection);
      final offsetDelta =
          isVertical ? Offset(0, physicalDelta) : Offset(physicalDelta, 0);
      if (arbiter.isDeltaAllowed(offsetDelta)) {
        if (toEdge != 0) {
          super.applyUserOffset(toEdge);
        }
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
