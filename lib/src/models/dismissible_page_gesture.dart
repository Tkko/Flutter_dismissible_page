part of '../dismissible_page.dart';

/// Where on the page a drag may start.
@immutable
class DismissiblePageDragRegion {
  /// A drag may start anywhere on the page.
  const DismissiblePageDragRegion.anywhere()
      : _side = null,
        _extent = 0,
        _test = null;

  /// A drag may only start within `extent` logical pixels of `side`, for
  /// example the top strip of a sheet with `DismissiblePageSide.up`.
  ///
  /// [DismissiblePageSide.start] and [DismissiblePageSide.end] follow
  /// [Directionality].
  const DismissiblePageDragRegion.edge(
    DismissiblePageSide this._side,
    this._extent,
  )   : assert(_extent > 0, 'extent must be greater than 0'),
        _test = null;

  /// A drag may only start where `test` returns true, given the touch position
  /// in the page's coordinates and the page size.
  const DismissiblePageDragRegion.custom(
    bool Function(Offset position, Size size) this._test,
  )   : _side = null,
        _extent = 0;

  final DismissiblePageSide? _side;
  final double _extent;
  final bool Function(Offset position, Size size)? _test;

  /// Whether a drag may start at [position] on a page of [size].
  bool contains(Offset position, Size size, TextDirection textDirection) {
    final test = _test;
    if (test != null) return test(position, size);
    final side = _side;
    if (side == null) return true;
    final isLtr = textDirection == TextDirection.ltr;
    return switch (side) {
      DismissiblePageSide.up => position.dy <= _extent,
      DismissiblePageSide.down => position.dy >= size.height - _extent,
      DismissiblePageSide.start =>
        isLtr ? position.dx <= _extent : position.dx >= size.width - _extent,
      DismissiblePageSide.end =>
        isLtr ? position.dx >= size.width - _extent : position.dx <= _extent,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageDragRegion &&
          _side == other._side &&
          _extent == other._extent &&
          _test == other._test;

  @override
  int get hashCode => Object.hash(_side, _extent, _test);
}

/// What counts as a dismissing drag of a [DismissiblePage].
///
/// How the released page then moves is configured by
/// [DismissiblePageMotion].
@immutable
class DismissiblePageGesture {
  ///
  const DismissiblePageGesture({
    this.dismissThresholds = const <DismissiblePageSide, double>{},
    this.flingVelocity = 1000,
    this.flingMinDistance = 0.1,
    this.cancelVelocity = 300,
    this.lockAxis = false,
    this.dragRegion = const DismissiblePageDragRegion.anywhere(),
  })  : assert(flingVelocity > 0, 'flingVelocity must be greater than 0'),
        assert(cancelVelocity >= 0, 'cancelVelocity must not be negative'),
        assert(
          flingMinDistance >= 0 && flingMinDistance <= 1,
          'flingMinDistance must be between 0.0 and 1.0',
        );

  /// Page displacement thresholds (0.0 to 1.0) per destination side.
  ///
  /// Up/down use a fraction of page height; start/end use page width.
  /// Start/end follow [Directionality]. Missing sides default to 0.18.
  /// With [DismissiblePageDismissDirection.all], either axis can dismiss.
  /// These thresholds are independent of
  /// [DismissiblePageTransform.maxTransformValue].
  /// A fast outward fling can dismiss before reaching a distance threshold.
  final Map<DismissiblePageSide, double> dismissThresholds;

  /// Release speed, in page pixels per second, above which an outward drag is
  /// a fling that dismisses the page before it reaches its dismiss threshold.
  ///
  /// Page pixels are [DismissiblePageTransform.dragSensitivity] times finger
  /// pixels. Use [double.infinity] to dismiss by distance only.
  final double flingVelocity;

  /// Fraction of the page dimension the page must have moved before an
  /// outward fling can dismiss it, so a flick from a near-resting page does
  /// not.
  final double flingMinDistance;

  /// Release speed, in page pixels per second, above which a drag back towards
  /// the origin cancels the dismissal, even when the page is past its
  /// threshold.
  ///
  /// It is much lower than [flingVelocity] on purpose: changing your mind
  /// needs only a hint, while dismissing needs clear intent, so a page that is
  /// drifting back is never dismissed by accident. Use 0 to cancel on any
  /// inward movement, or [double.infinity] to never cancel.
  final double cancelVelocity;

  /// With [DismissiblePageDismissDirection.all], whether a drag sticks to the
  /// axis it started along, so a diagonal drag cannot dismiss sideways.
  ///
  /// Has no effect for other directions, which only move along one axis.
  final bool lockAxis;

  /// Where on the page a drag may start.
  ///
  /// It limits the page's own drag and the pull of a scrollable resting at
  /// its edge. A scrollable keeps scrolling normally outside of it.
  final DismissiblePageDragRegion dragRegion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageGesture &&
          mapEquals(dismissThresholds, other.dismissThresholds) &&
          flingVelocity == other.flingVelocity &&
          flingMinDistance == other.flingMinDistance &&
          cancelVelocity == other.cancelVelocity &&
          lockAxis == other.lockAxis &&
          dragRegion == other.dragRegion;

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(
          dismissThresholds.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        flingVelocity,
        flingMinDistance,
        cancelVelocity,
        lockAxis,
        dragRegion,
      );
}
