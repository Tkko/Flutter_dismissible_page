part of '../dismissible_page.dart';

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
    required this.onDismissed,
    required TickerProvider vsync,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
  }) : assert(
          dismissThresholds.values.every((value) => value >= 0 && value <= 1),
          'Dismiss thresholds must be between 0.0 and 1.0',
        ) {
    _animationController = AnimationController(
      duration: reverseDuration,
      vsync: vsync,
    )
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
  }

  final DismissiblePageDismissDirection direction;
  final Map<DismissiblePageSide, double> dismissThresholds;
  final DismissiblePageBackground background;
  final DismissiblePageRadius borderRadius;
  final double minScale;
  final double maxTransformValue;
  final double dragSensitivity;
  final Duration reverseDuration;

  VoidCallback onDismissed;
  VoidCallback? onDragStart;
  VoidCallback? onDragEnd;
  VoidCallback? onDragCancel;
  ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  late final AnimationController _animationController;

  Offset _dragOffset = Offset.zero;
  Offset _animationStartOffset = Offset.zero;
  bool _isDragging = false;
  Size _layoutSize = Size.zero;
  TextDirection _textDirection = TextDirection.ltr;

  bool get isDragging => _isDragging;
  bool get isAnimating => _animationController.isAnimating;
  bool get isOffsetNonZero => _dragOffset != Offset.zero;
  Offset get offset => _dragOffset;

  void updateLayout(Size size, TextDirection textDirection) {
    _layoutSize = size;
    _textDirection = textDirection;
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

  DismissiblePageDragUpdateDetails get currentDetails =>
      DismissiblePageDragUpdateDetails(
        offset: _dragOffset,
        progress: progress,
        radius: radius,
        opacity: opacity,
        scale: scale,
      );

  void setOffset(Offset newOffset) {
    _dragOffset = newOffset;
    onDragUpdate?.call(currentDetails);
    notifyListeners();
  }

  void startDrag() {
    if (_isDragging) return;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _isDragging = true;
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

    _dragOffset += effectiveDelta;
    onDragUpdate?.call(currentDetails);
    notifyListeners();
  }

  void endDrag({double velocity = 0.0}) {
    if (!_isDragging) return;
    _isDragging = false;

    final shouldDismiss = _hasReachedDismissThreshold ||
        (velocity.abs() > 800 && _isVelocityOutward(velocity));

    if (shouldDismiss && isOffsetNonZero) {
      onDragEnd?.call();
      onDismissed();
    } else {
      animateToZero();
      onDragEnd?.call();
    }
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

  bool _isVelocityOutward(double velocity) {
    final isHorizontal = switch (direction) {
      DismissiblePageDismissDirection.horizontal ||
      DismissiblePageDismissDirection.startToEnd ||
      DismissiblePageDismissDirection.endToStart =>
        true,
      DismissiblePageDismissDirection.all =>
        _dragOffset.dx.abs() > _dragOffset.dy.abs(),
      _ => false,
    };
    final coordinate = isHorizontal ? _dragOffset.dx : _dragOffset.dy;
    final velocityDelta =
        isHorizontal ? Offset(velocity, 0) : Offset(0, velocity);

    return coordinate != 0 &&
        coordinate * velocity > 0 &&
        isDeltaAllowed(velocityDelta);
  }

  void cancelDrag() {
    if (!_isDragging) return;
    _isDragging = false;
    animateToZero();
    onDragCancel?.call();
  }

  void animateToZero() {
    _animationStartOffset = _dragOffset;
    _animationController.forward(from: 0);
  }

  void _handleAnimationTick() {
    _dragOffset = Offset.lerp(
      _animationStartOffset,
      Offset.zero,
      Curves.easeOutCubic.transform(_animationController.value),
    )!;
    onDragUpdate?.call(currentDetails);
    notifyListeners();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _dragOffset = Offset.zero;
      _animationStartOffset = Offset.zero;
      _animationController.reset();
      onDragUpdate?.call(currentDetails);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
