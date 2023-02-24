part of 'dismissible_page.dart';

@visibleForTesting
class SingleAxisDismissiblePage extends StatefulWidget {
  const SingleAxisDismissiblePage({
    required this.child,
    required this.onDismissed,
    required this.isFullScreen,
    required this.backgroundColor,
    required this.direction,
    required this.dismissThresholds,
    required this.dragStartBehavior,
    required this.dragSensitivity,
    required this.minRadius,
    required this.minScale,
    required this.maxRadius,
    required this.maxTransformValue,
    required this.startingOpacity,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragUpdate,
    required this.reverseDuration,
    required this.hitTestBehavior,
    required this.contentPadding,
    Key? key,
  }) : super(key: key);

  final double startingOpacity;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final VoidCallback onDismissed;
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;
  final bool isFullScreen;
  final double minScale;
  final double minRadius;
  final double maxRadius;
  final double maxTransformValue;
  final Widget child;
  final Color backgroundColor;
  final DismissiblePageDismissDirection direction;
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;
  final double dragSensitivity;
  final DragStartBehavior dragStartBehavior;
  final Duration reverseDuration;
  final HitTestBehavior hitTestBehavior;
  final EdgeInsetsGeometry contentPadding;

  @override
  _SingleAxisDismissiblePageState createState() =>
      _SingleAxisDismissiblePageState();
}

class _SingleAxisDismissiblePageState extends State<SingleAxisDismissiblePage>
    with TickerProviderStateMixin, _DismissiblePageMixin {
  late Animation<Offset> _moveAnimation;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    _moveController
      ..addStatusListener(_handleDismissStatusChanged)
      ..addListener(_moveAnimationListener);
    _updateMoveAnimation();
  }

  void _moveAnimationListener() {
    if (widget.onDragUpdate != null) {
      widget.onDragUpdate!.call(
        DismissiblePageDragUpdateDetails(
          overallDragValue:
              min(_dragExtent / context.size!.height, widget.maxTransformValue),
          radius: _radius,
          opacity: _opacity,
          offset: _offset,
          scale: _scale ?? 0.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _moveController
      ..removeStatusListener(_handleDismissStatusChanged)
      ..removeListener(_moveAnimationListener)
      ..dispose();
    super.dispose();
  }

  bool get _directionIsXAxis {
    return widget.direction == DismissiblePageDismissDirection.horizontal ||
        widget.direction == DismissiblePageDismissDirection.endToStart ||
        widget.direction == DismissiblePageDismissDirection.startToEnd;
  }

  DismissiblePageDismissDirection? _extentToDirection(double extent) {
    if (extent == 0.0) return null;
    if (_directionIsXAxis) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          return extent < 0
              ? DismissiblePageDismissDirection.startToEnd
              : DismissiblePageDismissDirection.endToStart;
        case TextDirection.ltr:
          return extent > 0
              ? DismissiblePageDismissDirection.startToEnd
              : DismissiblePageDismissDirection.endToStart;
      }
    }
    return extent > 0
        ? DismissiblePageDismissDirection.down
        : DismissiblePageDismissDirection.up;
  }

  DismissiblePageDismissDirection? get _dismissDirection =>
      _extentToDirection(_dragExtent);

  double get _overallDragAxisExtent {
    final size = context.size;
    return _directionIsXAxis ? size!.width : size!.height;
  }

  void _handleDragStart([DragStartDetails? _]) {
    widget.onDragStart?.call();
    _dragUnderway = true;
    if (_moveController.isAnimating) {
      _dragExtent =
          _moveController.value * _overallDragAxisExtent * _dragExtent.sign;
      _moveController.stop();
    } else {
      _dragExtent = 0.0;
      _moveController.value = 0.0;
    }
    setState(_updateMoveAnimation);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController.isAnimating) return;

    final delta = details.primaryDelta;
    final oldDragExtent = _dragExtent;
    bool _(DismissiblePageDismissDirection d) => widget.direction == d;

    if (_(DismissiblePageDismissDirection.horizontal) ||
        _(DismissiblePageDismissDirection.vertical)) {
      _dragExtent += delta!;
    } else if (_(DismissiblePageDismissDirection.up)) {
      if (_dragExtent + delta! < 0) _dragExtent += delta;
    } else if (_(DismissiblePageDismissDirection.down)) {
      if (_dragExtent + delta! > 0) _dragExtent += delta;
    } else if (_(DismissiblePageDismissDirection.endToStart)) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          if (_dragExtent + delta! > 0) _dragExtent += delta;
          break;
        default:
          if (_dragExtent + delta! < 0) _dragExtent += delta;
      }
    } else if (_(DismissiblePageDismissDirection.startToEnd)) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          if (_dragExtent + delta! < 0) _dragExtent += delta;
          break;
        default:
          if (_dragExtent + delta! > 0) _dragExtent += delta;
      }
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(_updateMoveAnimation);
    }

    if (!_moveController.isAnimating) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _updateMoveAnimation() {
    final end = _dragExtent.sign * widget.dragSensitivity;
    _moveAnimation = _moveController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: _directionIsXAxis ? Offset(end, 0) : Offset(0, end),
      ),
    );
  }

  double get _dismissThreshold =>
      widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold;

  void _handleDragEnd([DragEndDetails? _]) {
    if (!_isActive || _moveController.isAnimating) return;
    _dragUnderway = false;
    if (!_moveController.isDismissed) {
      if (_moveController.value > _dismissThreshold) {
        widget.onDismissed.call();
      } else {
        _moveController
          ..reverseDuration =
              widget.reverseDuration * (1 / _moveController.value)
          ..reverse();
        widget.onDragEnd?.call();
      }
    }
  }

  void _handleDismissStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      widget.onDismissed();
    }
  }

  double get _dragValue => _directionIsXAxis
      ? _moveAnimation.value.dx.abs()
      : _moveAnimation.value.dy.abs();

  double get _getDx {
    if (_directionIsXAxis) {
      if (_moveAnimation.value.dx.isNegative) {
        return max(_moveAnimation.value.dx, -widget.maxTransformValue);
      } else {
        return min(_moveAnimation.value.dx, widget.maxTransformValue);
      }
    }
    return _moveAnimation.value.dx;
  }

  double get _getDy {
    if (!_directionIsXAxis) {
      if (_moveAnimation.value.dy.isNegative) {
        return max(_moveAnimation.value.dy, -widget.maxTransformValue);
      } else {
        return min(_moveAnimation.value.dy, widget.maxTransformValue);
      }
    }
    return _moveAnimation.value.dy;
  }

  Offset get _offset => Offset(_getDx, _getDy);

  double? get _scale => lerpDouble(1, widget.minScale, _dragValue);

  double get _radius =>
      lerpDouble(widget.minRadius, widget.maxRadius, _dragValue)!;

  double get _opacity => (widget.startingOpacity - _dragValue).clamp(.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: widget.hitTestBehavior,
      dragStartBehavior: widget.dragStartBehavior,
      child: _DismissiblePageListener(
        onStart: (_) => _handleDragStart(),
        onUpdate: _handleDragUpdate,
        onEnd: _handleDragEnd,
        parentState: this,
        direction: widget.direction,
        child: AnimatedBuilder(
          animation: _moveAnimation,
          builder: (BuildContext context, Widget? child) {
            final backgroundColor = widget.backgroundColor == Colors.transparent
                ? Colors.transparent
                : widget.backgroundColor.withOpacity(_opacity);

            return Container(
              padding: widget.contentPadding,
              color: backgroundColor,
              child: FractionalTranslation(
                translation: _offset,
                child: Transform.scale(
                  scale: _scale ?? 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_radius),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
