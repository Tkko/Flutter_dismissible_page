part of '../dismissible_page.dart';

enum _FlingDirection { outward, inward, none }

/// Manages and coordinates the drag and dismiss state for a [DismissiblePage].
///
/// Follows Single Responsibility Principle (SRP) by isolating state calculations,
/// directional constraints, and offset transformations from rendering.
class _DismissibleArbiter extends ChangeNotifier {
  _DismissibleArbiter({
    required this.direction,
    required this.gesture,
    required this.background,
    required this.borderRadius,
    required this.transform,
    required this.motion,
    required this.onDismissed,
    required TickerProvider vsync,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
    this.onDragEvent,
    this.onWillDismiss,
    this.onDismissStart,
  }) : assert(
          _validThresholds(gesture.dismissThresholds),
          'Dismiss thresholds must be between 0.0 and 1.0',
        ) {
    _animationController = AnimationController.unbounded(vsync: vsync)
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
  }

  DismissiblePageDismissDirection direction;
  DismissiblePageGesture gesture;
  DismissiblePageBackground background;
  DismissiblePageRadius borderRadius;
  DismissiblePageTransform transform;
  DismissiblePageMotion motion;

  VoidCallback onDismissed;
  VoidCallback? onDragStart;
  VoidCallback? onDragEnd;
  VoidCallback? onDragCancel;
  ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;
  ValueChanged<DismissiblePageEvent>? onDragEvent;
  FutureOr<bool> Function()? onWillDismiss;
  VoidCallback? onDismissStart;

  double get minScale => transform.minScale;
  double get maxTransformValue => transform.maxTransformValue;
  double get dragSensitivity => transform.dragSensitivity;
  Map<DismissiblePageSide, double> get dismissThresholds =>
      gesture.dismissThresholds;

  /// Whether the pointer that is down began inside
  /// [DismissiblePageGesture.dragRegion]. A drag that began outside of it
  /// never moves the page.
  bool pointerInRegion = true;

  Size get layoutSize => _layoutSize;
  TextDirection get textDirection => _textDirection;

  late final AnimationController _animationController;

  Offset _dragOffset = Offset.zero;
  Offset _animationStartOffset = Offset.zero;
  Offset _animationTargetOffset = Offset.zero;
  bool _isPastThreshold = false;
  bool _isExiting = false;
  bool _isDisposed = false;
  // Counts confirmations asked of [onWillDismiss], so that an answer to a
  // question that has since been abandoned is ignored.
  int _confirmation = 0;
  bool _isConfirming = false;
  Axis? _lockedAxis;
  DismissiblePageDragUpdateDetails? _details;
  bool _isDragging = false;
  Size _layoutSize = Size.zero;
  TextDirection _textDirection = TextDirection.ltr;

  bool get isDragging => _isDragging;

  /// Whether the page is leaving the screen.
  bool get isDismissing => _isExiting;
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
    required DismissiblePageGesture gesture,
    required DismissiblePageBackground background,
    required DismissiblePageRadius borderRadius,
    required DismissiblePageTransform transform,
    required DismissiblePageMotion motion,
  }) {
    assert(
      _validThresholds(gesture.dismissThresholds),
      'Dismiss thresholds must be between 0.0 and 1.0',
    );
    this.direction = direction;
    this.gesture = gesture;
    this.background = background;
    this.borderRadius = borderRadius;
    this.transform = transform;
    this.motion = motion;
    _details = null;
  }

  void updateCallbacks({
    required VoidCallback onDismissed,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
    VoidCallback? onDragCancel,
    ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate,
    ValueChanged<DismissiblePageEvent>? onDragEvent,
    FutureOr<bool> Function()? onWillDismiss,
    VoidCallback? onDismissStart,
  }) {
    this.onDismissed = onDismissed;
    this.onDragStart = onDragStart;
    this.onDragEnd = onDragEnd;
    this.onDragCancel = onDragCancel;
    this.onDragUpdate = onDragUpdate;
    this.onDragEvent = onDragEvent;
    this.onWillDismiss = onWillDismiss;
    this.onDismissStart = onDismissStart;
  }

  void _fireDragStart() {
    onDragStart?.call();
    onDragEvent?.call(const DismissiblePageDragStartEvent());
  }

  void _fireDragEnd() {
    onDragEnd?.call();
    onDragEvent?.call(const DismissiblePageDragEndEvent());
  }

  void _fireDragCancel() {
    onDragCancel?.call();
    onDragEvent?.call(const DismissiblePageDragCancelEvent());
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
        willDismiss: _hasReachedDismissThreshold,
      );

  void _publish(Offset newOffset) {
    _dragOffset = newOffset;
    _details = null;
    _tickThresholdHaptics();
    onDragUpdate?.call(currentDetails);
    onDragEvent?.call(DismissiblePageDragUpdateEvent(currentDetails));
    notifyListeners();
  }

  void setOffset(Offset newOffset) {
    if (newOffset == _dragOffset) return;
    _publish(newOffset);
  }

  void startDrag() {
    if (_isDragging || _isConfirming) return;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _isDragging = true;
    _isPastThreshold = _hasReachedDismissThreshold;
    _fireDragStart();
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
    if (_isConfirming) return;
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
        if (gesture.lockAxis && effectiveDelta != Offset.zero) {
          _lockedAxis ??= effectiveDelta.dx.abs() > effectiveDelta.dy.abs()
              ? Axis.horizontal
              : Axis.vertical;
          effectiveDelta = _lockedAxis == Axis.horizontal
              ? Offset(effectiveDelta.dx, 0)
              : Offset(0, effectiveDelta.dy);
        }
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
    _lockedAxis = null;

    final shouldDismiss = switch (_flingDirection(velocity)) {
      _FlingDirection.outward => true,
      _FlingDirection.inward => false,
      _FlingDirection.none => _hasReachedDismissThreshold,
    };

    if (shouldDismiss && isOffsetNonZero) {
      _fireDragEnd();
      _confirmDismiss(
        onConfirmed: (resumedVelocity) {
          onDismissStart?.call();
          if (motion.continueOnDismiss) {
            _isExiting = true;
            animateOut(resumedVelocity);
          }
          onDismissed();
        },
        onDenied: (resumedVelocity) {
          if (isOffsetNonZero) animateToZero(resumedVelocity);
        },
        velocity: velocity,
      );
    } else {
      if (isOffsetNonZero) animateToZero(velocity);
      _fireDragEnd();
    }
  }

  /// Asks [onWillDismiss] whether a dismissal may go ahead.
  ///
  /// A synchronous answer is acted on at once, with the release [velocity].
  /// A pending one holds the page where it is, ignoring new drags, and the
  /// continuation resumes from rest. An answer that arrives after the
  /// question was abandoned (the page was reset or disposed) is dropped.
  void _confirmDismiss({
    required void Function(double velocity) onConfirmed,
    required void Function(double velocity) onDenied,
    double velocity = 0,
  }) {
    final callback = onWillDismiss;
    if (callback == null) {
      onConfirmed(velocity);
      return;
    }
    final answer = callback();
    if (answer is bool) {
      answer ? onConfirmed(velocity) : onDenied(velocity);
      return;
    }

    final id = ++_confirmation;
    _isConfirming = true;
    bool isCurrent() => !_isDisposed && id == _confirmation;
    unawaited(
      answer.then(
        (allowed) {
          if (!isCurrent()) return;
          _isConfirming = false;
          allowed ? onConfirmed(0) : onDenied(0);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (isCurrent()) {
            _isConfirming = false;
            onDenied(0);
          }
          Error.throwWithStackTrace(error, stackTrace);
        },
      ),
    );
  }

  /// Abandons any drag or rebound immediately and returns to the origin.
  void reset() {
    final wasDragging = _isDragging;
    _isDragging = false;
    _lockedAxis = null;
    _confirmation++;
    _isConfirming = false;
    _animationController.stop();
    _isExiting = false;
    _animationStartOffset = Offset.zero;
    _animationTargetOffset = Offset.zero;
    setOffset(Offset.zero);
    if (wasDragging) _fireDragCancel();
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

  /// Reads a release as a deliberate outward fling, a retreat back towards the
  /// origin, or neither.
  ///
  /// The two are deliberately asymmetric: a retreat needs only a hint of
  /// speed, an outward fling needs a clearly fast one and some distance. When
  /// in doubt the page stays.
  _FlingDirection _flingDirection(double velocity) {
    final isHorizontal = _isHorizontalAxis;
    final coordinate = isHorizontal ? _dragOffset.dx : _dragOffset.dy;
    if (coordinate == 0) return _FlingDirection.none;

    final speed = velocity.abs();
    if (coordinate * velocity < 0) {
      return speed > gesture.cancelVelocity
          ? _FlingDirection.inward
          : _FlingDirection.none;
    }
    if (speed <= gesture.flingVelocity) return _FlingDirection.none;

    final extent = isHorizontal ? _layoutSize.width : _layoutSize.height;
    if (extent <= 0 || coordinate.abs() / extent < gesture.flingMinDistance) {
      return _FlingDirection.none;
    }
    return isDeltaAllowed(_velocityVector(velocity))
        ? _FlingDirection.outward
        : _FlingDirection.none;
  }

  void cancelDrag() {
    if (!_isDragging) return;
    _isDragging = false;
    _lockedAxis = null;
    if (isOffsetNonZero) animateToZero();
    _fireDragCancel();
  }

  void animateToZero([double velocity = 0]) {
    _animateTo(Offset.zero, _velocityVector(velocity));
  }

  /// Dismisses the page without a drag: it winds up slightly against the
  /// exit direction, then accelerates off-screen while [onDismissed] runs.
  ///
  /// Leaves from [side], or from the side the configured direction dismisses
  /// towards. Does nothing while an exit is already running.
  void dismiss({DismissiblePageSide? side}) {
    if (_isExiting || _isConfirming) return;
    _confirmDismiss(
      onConfirmed: (_) => _dismissNow(side),
      onDenied: (_) {
        if (isOffsetNonZero) animateToZero();
      },
    );
  }

  void _dismissNow(DismissiblePageSide? side) {
    _isExiting = true;
    onDismissStart?.call();
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
    final exit = motion.exit;
    _animateTo(
      target,
      Offset.zero,
      duration:
          exit is DismissiblePageCurveExit ? exit.duration : _kDismissDuration,
      curve: exit is DismissiblePageCurveExit ? exit.curve : _kExitCurve,
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

  void animateOut(double velocity) {
    final target = _isHorizontalAxis
        ? Offset(_dragOffset.dx.sign * _layoutSize.width, _dragOffset.dy)
        : Offset(_dragOffset.dx, _dragOffset.dy.sign * _layoutSize.height);
    final distance = (target - _dragOffset).distance;
    final speed = velocity.abs();

    final exit = motion.exit;
    if (exit is DismissiblePageCurveExit) {
      _animateTo(
        target,
        Offset.zero,
        duration: exit.duration,
        curve: exit.curve,
      );
      return;
    }

    if (speed < _kMomentumVelocity) {
      // Released slowly, so there is no momentum to carry. Easing out would
      // make the page lurch away from a standstill; it is pushed off with a
      // gentle acceleration instead.
      _animateTo(
        target,
        Offset.zero,
        duration: _kSlowExitDuration,
        curve: Curves.easeIn,
      );
      return;
    }

    // easeOutCubic starts at three times the average speed, so this makes the
    // page leave at the speed it was released at.
    final milliseconds = _kEaseOutCubicStartSlope * 1000 * distance / speed;
    _animateTo(
      target,
      _velocityVector(velocity),
      duration: Duration(
        milliseconds: milliseconds
            .clamp(_kMomentumExitMinMs, _kMomentumExitMaxMs)
            .round(),
      ),
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
    if (duration == null && rebound is DismissiblePageSpringRebound) {
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
          tolerance: Tolerance(
            distance: _kSpringDistanceTolerance / delta.distance,
            velocity: _kSpringVelocityTolerance / delta.distance,
          ),
        ),
      );
    } else {
      _animationController.animateTo(
        1,
        duration: duration ??
            (rebound is DismissiblePageCurveRebound
                ? rebound.duration
                : _kDismissDuration),
        curve: curve ??
            (rebound is DismissiblePageCurveRebound
                ? rebound.curve
                : Curves.linear),
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
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }
}
