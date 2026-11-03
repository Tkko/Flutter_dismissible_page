part of '../dismissible_page.dart';

/// Winds up by about 1.5% of the travel, then accelerates away. Unlike
/// [Curves.easeInBack], whose wind-up is roughly 10%, it reads as a nudge
/// instead of a bounce.
const Curve _kExitCurve = Cubic(0.55, -0.12, 0.85, 0.45);

/// Which way a released drag is flung relative to the page's offset.
enum _FlingDirection { outward, inward, none }

/// Manages and coordinates the drag and dismiss state for a [DismissiblePage].
///
/// Follows Single Responsibility Principle (SRP) by isolating state calculations,
/// directional constraints, and offset transformations from rendering.
class _DismissibleArbiter extends ChangeNotifier {
  _DismissibleArbiter({
    required this.direction,
    required this.dismissThresholds,
    required this.background,
    required this.borderRadius,
    required this.minScale,
    required this.maxTransformValue,
    required this.dragSensitivity,
    required this.reverseDuration,
    required this.motion,
    required this.onDismissed,
    required TickerProvider vsync,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
  }) : assert(
          _validThresholds(dismissThresholds),
          'Dismiss thresholds must be between 0.0 and 1.0',
        ) {
    _animationController = AnimationController.unbounded(vsync: vsync)
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
  }

  DismissiblePageDismissDirection direction;
  Map<DismissiblePageSide, double> dismissThresholds;
  DismissiblePageBackground background;
  DismissiblePageRadius borderRadius;
  double minScale;
  double maxTransformValue;
  double dragSensitivity;
  Duration reverseDuration;
  DismissiblePageMotion motion;

  VoidCallback onDismissed;
  VoidCallback? onDragStart;
  VoidCallback? onDragEnd;
  VoidCallback? onDragCancel;
  ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  late final AnimationController _animationController;

  Offset _dragOffset = Offset.zero;
  Offset _animationStartOffset = Offset.zero;
  Offset _animationTargetOffset = Offset.zero;
  bool _isPastThreshold = false;
  bool _isExiting = false;
  DismissiblePageDragUpdateDetails? _details;
  bool _isDragging = false;
  Size _layoutSize = Size.zero;
  TextDirection _textDirection = TextDirection.ltr;

  bool get isDragging => _isDragging;
  bool get isAnimating => _animationController.isAnimating;
  bool get isOffsetNonZero => _dragOffset != Offset.zero;
  Offset get offset => _dragOffset;

  void updateLayout(Size size, TextDirection textDirection) {
    if (_layoutSize == size && _textDirection == textDirection) return;
    _layoutSize = size;
    _textDirection = textDirection;
    _details = null;
  }

  static bool _validThresholds(Map<DismissiblePageSide, double> thresholds) =>
      thresholds.values.every((value) => value >= 0 && value <= 1);

  /// Applies new configuration in place so an active drag or rebound
  /// survives rebuilds of the owning widget.
  void updateConfig({
    required DismissiblePageDismissDirection direction,
    required Map<DismissiblePageSide, double> dismissThresholds,
    required DismissiblePageBackground background,
    required DismissiblePageRadius borderRadius,
    required double minScale,
    required double maxTransformValue,
    required double dragSensitivity,
    required Duration reverseDuration,
    required DismissiblePageMotion motion,
  }) {
    assert(
      _validThresholds(dismissThresholds),
      'Dismiss thresholds must be between 0.0 and 1.0',
    );
    this.direction = direction;
    this.dismissThresholds = dismissThresholds;
    this.background = background;
    this.borderRadius = borderRadius;
    this.minScale = minScale;
    this.maxTransformValue = maxTransformValue;
    this.dragSensitivity = dragSensitivity;
    this.reverseDuration = reverseDuration;
    this.motion = motion;
    _details = null;
  }

  void updateCallbacks({
    required VoidCallback onDismissed,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
    VoidCallback? onDragCancel,
    ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate,
  }) {
    this.onDismissed = onDismissed;
    this.onDragStart = onDragStart;
    this.onDragEnd = onDragEnd;
    this.onDragCancel = onDragCancel;
    this.onDragUpdate = onDragUpdate;
  }

  double get progress {
    if (_layoutSize.isEmpty) return 0;
    if (maxTransformValue == 0) {
      return _dragOffset == Offset.zero ? 0 : 1;
    }

    final normalizedX =
        (_dragOffset.dx.abs() / _layoutSize.width) / maxTransformValue;
    final normalizedY =
        (_dragOffset.dy.abs() / _layoutSize.height) / maxTransformValue;

    switch (direction) {
      case DismissiblePageDismissDirection.horizontal:
      case DismissiblePageDismissDirection.startToEnd:
      case DismissiblePageDismissDirection.endToStart:
        return normalizedX.clamp(0, 1);
      case DismissiblePageDismissDirection.vertical:
      case DismissiblePageDismissDirection.up:
      case DismissiblePageDismissDirection.down:
        return normalizedY.clamp(0, 1);
      case DismissiblePageDismissDirection.all:
        return max(normalizedX, normalizedY).clamp(0, 1);
      case DismissiblePageDismissDirection.none:
        return 0;
    }
  }

  double get radius => borderRadius.resolveRadius(progress);
  double get scale => lerpDouble(1, minScale, progress)!;
  double get opacity {
    final color = background.resolveColor(progress);
    if (color == null) return (1.0 - progress).clamp(0.0, 1.0);
    return color.a;
  }

  /// Snapshot of the current drag state, computed once per offset change.
  DismissiblePageDragUpdateDetails get currentDetails =>
      _details ??= DismissiblePageDragUpdateDetails(
        offset: _dragOffset,
        progress: progress,
        radius: radius,
        opacity: opacity,
        scale: scale,
      );

  void _publish(Offset newOffset) {
    _dragOffset = newOffset;
    _details = null;
    _tickThresholdHaptics();
    onDragUpdate?.call(currentDetails);
    notifyListeners();
  }

  void setOffset(Offset newOffset) {
    if (newOffset == _dragOffset) return;
    _publish(newOffset);
  }

  void startDrag() {
    if (_isDragging) return;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _isDragging = true;
    _isPastThreshold = _hasReachedDismissThreshold;
    onDragStart?.call();
    notifyListeners();
  }

  /// Evaluates whether a delta can be consumed in the configured direction.
  bool isDeltaAllowed(Offset delta) {
    if (direction == DismissiblePageDismissDirection.none) return false;
    if (direction == DismissiblePageDismissDirection.all) return true;

    final isHorizontal =
        direction == DismissiblePageDismissDirection.horizontal ||
            direction == DismissiblePageDismissDirection.startToEnd ||
            direction == DismissiblePageDismissDirection.endToStart;

    if (isHorizontal) {
      if (delta.dx == 0) return false;
      switch (direction) {
        case DismissiblePageDismissDirection.horizontal:
          return true;
        case DismissiblePageDismissDirection.startToEnd:
          return _textDirection == TextDirection.ltr
              ? delta.dx > 0
              : delta.dx < 0;
        case DismissiblePageDismissDirection.endToStart:
          return _textDirection == TextDirection.ltr
              ? delta.dx < 0
              : delta.dx > 0;
        default:
          return false;
      }
    } else {
      if (delta.dy == 0) return false;
      switch (direction) {
        case DismissiblePageDismissDirection.vertical:
          return true;
        case DismissiblePageDismissDirection.down:
          return delta.dy > 0;
        case DismissiblePageDismissDirection.up:
          return delta.dy < 0;
        default:
          return false;
      }
    }
  }

  /// Applies a drag delta constrained to allowed axes.
  void applyDelta(Offset delta) {
    var effectiveDelta = delta * dragSensitivity;

    switch (direction) {
      case DismissiblePageDismissDirection.vertical:
        effectiveDelta = Offset(0, effectiveDelta.dy);
      case DismissiblePageDismissDirection.down:
        final nextY = _dragOffset.dy + effectiveDelta.dy;
        effectiveDelta =
            Offset(0, nextY >= 0 ? effectiveDelta.dy : -_dragOffset.dy);
      case DismissiblePageDismissDirection.up:
        final nextY = _dragOffset.dy + effectiveDelta.dy;
        effectiveDelta =
            Offset(0, nextY <= 0 ? effectiveDelta.dy : -_dragOffset.dy);
      case DismissiblePageDismissDirection.horizontal:
        effectiveDelta = Offset(effectiveDelta.dx, 0);
      case DismissiblePageDismissDirection.startToEnd:
        final sign = _textDirection == TextDirection.ltr ? 1 : -1;
        final nextX = _dragOffset.dx + effectiveDelta.dx;
        effectiveDelta =
            Offset(sign * nextX >= 0 ? effectiveDelta.dx : -_dragOffset.dx, 0);
      case DismissiblePageDismissDirection.endToStart:
        final sign = _textDirection == TextDirection.ltr ? -1 : 1;
        final nextX = _dragOffset.dx + effectiveDelta.dx;
        effectiveDelta =
            Offset(sign * nextX >= 0 ? effectiveDelta.dx : -_dragOffset.dx, 0);
      case DismissiblePageDismissDirection.all:
        break;
      case DismissiblePageDismissDirection.none:
        return;
    }

    if (effectiveDelta == Offset.zero) return;

    if (!_isDragging) startDrag();

    _publish(_dragOffset + effectiveDelta);
  }

  /// Ends the drag. [velocity] is the release velocity along the dismiss axis,
  /// in the same pixels per second as the page [offset].
  void endDrag({double velocity = 0.0}) {
    if (!_isDragging) return;
    _isDragging = false;

    // A hard flick back towards the origin cancels a dismissal even when the
    // page was released past the distance threshold.
    final shouldDismiss = switch (_flingDirection(velocity)) {
      _FlingDirection.outward => true,
      _FlingDirection.inward => false,
      _FlingDirection.none => _hasReachedDismissThreshold,
    };

    if (shouldDismiss && isOffsetNonZero) {
      onDragEnd?.call();
      if (motion.continueOnDismiss) {
        _isExiting = true;
        animateOut(velocity);
      }
      onDismissed();
    } else {
      if (isOffsetNonZero) animateToZero(velocity);
      onDragEnd?.call();
    }
  }

  /// Abandons any drag or rebound immediately and returns to the origin.
  void reset() {
    final wasDragging = _isDragging;
    _isDragging = false;
    _animationController.stop();
    _isExiting = false;
    _animationStartOffset = Offset.zero;
    _animationTargetOffset = Offset.zero;
    setOffset(Offset.zero);
    if (wasDragging) onDragCancel?.call();
  }

  bool get _hasReachedDismissThreshold {
    if (_layoutSize.isEmpty) return false;

    final horizontalSide =
        (_dragOffset.dx > 0) == (_textDirection == TextDirection.ltr)
            ? DismissiblePageSide.end
            : DismissiblePageSide.start;
    final verticalSide =
        _dragOffset.dy > 0 ? DismissiblePageSide.down : DismissiblePageSide.up;

    return (isDeltaAllowed(Offset(_dragOffset.dx, 0)) &&
            _dragOffset.dx != 0 &&
            _dragOffset.dx.abs() / _layoutSize.width >=
                (dismissThresholds[horizontalSide] ?? _kDismissThreshold)) ||
        (isDeltaAllowed(Offset(0, _dragOffset.dy)) &&
            _dragOffset.dy != 0 &&
            _dragOffset.dy.abs() / _layoutSize.height >=
                (dismissThresholds[verticalSide] ?? _kDismissThreshold));
  }

  bool get _isHorizontalAxis => switch (direction) {
        DismissiblePageDismissDirection.horizontal ||
        DismissiblePageDismissDirection.startToEnd ||
        DismissiblePageDismissDirection.endToStart =>
          true,
        DismissiblePageDismissDirection.all =>
          _dragOffset.dx.abs() > _dragOffset.dy.abs(),
        _ => false,
      };

  _FlingDirection _flingDirection(double velocity) {
    if (velocity.abs() <= motion.flingVelocity) return _FlingDirection.none;

    final isHorizontal = _isHorizontalAxis;
    final coordinate = isHorizontal ? _dragOffset.dx : _dragOffset.dy;
    if (coordinate == 0) return _FlingDirection.none;
    if (coordinate * velocity < 0) return _FlingDirection.inward;

    final extent = isHorizontal ? _layoutSize.width : _layoutSize.height;
    if (extent <= 0 || coordinate.abs() / extent < motion.flingMinDistance) {
      return _FlingDirection.none;
    }
    return isDeltaAllowed(_velocityVector(velocity))
        ? _FlingDirection.outward
        : _FlingDirection.none;
  }

  void cancelDrag() {
    if (!_isDragging) return;
    _isDragging = false;
    if (isOffsetNonZero) animateToZero();
    onDragCancel?.call();
  }

  /// Eases the page back to the origin, carrying the release [velocity].
  void animateToZero([double velocity = 0]) {
    _animateTo(Offset.zero, _velocityVector(velocity));
  }

  /// Dismisses the page without a drag: it winds up slightly against the
  /// exit direction, then accelerates off-screen while [onDismissed] runs.
  ///
  /// Leaves from [side], or from the side the configured direction dismisses
  /// towards. Does nothing while an exit is already running.
  void dismiss({DismissiblePageSide? side}) {
    if (_isExiting) return;
    _isExiting = true;
    if (_layoutSize.isEmpty) {
      onDismissed();
      return;
    }

    final width = _layoutSize.width;
    final height = _layoutSize.height;
    final isLtr = _textDirection == TextDirection.ltr;
    final target = switch (side ?? _defaultExitSide) {
      DismissiblePageSide.up => Offset(0, -height),
      DismissiblePageSide.down => Offset(0, height),
      DismissiblePageSide.start => Offset(isLtr ? -width : width, 0),
      DismissiblePageSide.end => Offset(isLtr ? width : -width, 0),
    };
    _animateTo(
      target,
      Offset.zero,
      duration: const Duration(milliseconds: 340),
      curve: _kExitCurve,
    );
    onDismissed();
  }

  DismissiblePageSide get _defaultExitSide => switch (direction) {
        DismissiblePageDismissDirection.up => DismissiblePageSide.up,
        DismissiblePageDismissDirection.horizontal ||
        DismissiblePageDismissDirection.startToEnd =>
          DismissiblePageSide.end,
        DismissiblePageDismissDirection.endToStart => DismissiblePageSide.start,
        _ => DismissiblePageSide.down,
      };

  /// Carries the page off-screen in the drag direction.
  void animateOut(double velocity) {
    final target = _isHorizontalAxis
        ? Offset(_dragOffset.dx.sign * _layoutSize.width, _dragOffset.dy)
        : Offset(_dragOffset.dx, _dragOffset.dy.sign * _layoutSize.height);
    final distance = (target - _dragOffset).distance;
    final speed = velocity.abs();
    // easeOutCubic starts at three times the average speed, so this makes the
    // page leave at the speed it was released at.
    final milliseconds = speed == 0 ? 260 : 3000 * distance / speed;
    _animateTo(
      target,
      _velocityVector(velocity),
      duration: Duration(milliseconds: milliseconds.clamp(140, 260).round()),
      curve: Curves.easeOutCubic,
    );
  }

  Offset _velocityVector(double velocity) =>
      _isHorizontalAxis ? Offset(velocity, 0) : Offset(0, velocity);

  void _animateTo(
    Offset target,
    Offset velocity, {
    Duration? duration,
    Curve? curve,
  }) {
    final delta = target - _dragOffset;
    if (delta == Offset.zero) {
      setOffset(target);
      return;
    }
    _animationStartOffset = _dragOffset;
    _animationTargetOffset = target;
    _animationController.value = 0;

    final rebound = motion.rebound;
    if (duration == null && rebound.isSpring) {
      // The spring runs on the fraction of the way to the target, so the
      // velocity is projected onto the line between start and target.
      final fractionVelocity =
          (velocity.dx * delta.dx + velocity.dy * delta.dy) /
              delta.distanceSquared;
      _animationController.animateWith(
        SpringSimulation(
          rebound._spring,
          0,
          1,
          fractionVelocity,
          // Settle once the remaining motion is below a quarter pixel and 5px/s.
          tolerance: Tolerance(
            distance: 0.25 / delta.distance,
            velocity: 5 / delta.distance,
          ),
        ),
      );
    } else {
      _animationController.animateTo(
        1,
        duration: duration ?? reverseDuration,
        curve: curve ?? rebound.curve,
      );
    }
  }

  void _handleAnimationTick() {
    setOffset(
      Offset.lerp(
        _animationStartOffset,
        _animationTargetOffset,
        _animationController.value,
      )!,
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setOffset(_animationTargetOffset);
      _animationStartOffset = _animationTargetOffset;
    }
  }

  void _tickThresholdHaptics() {
    if (!_isDragging || !motion.thresholdHaptics) return;
    final isPast = _hasReachedDismissThreshold;
    if (isPast == _isPastThreshold) return;
    _isPastThreshold = isPast;
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
