import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kDismissThreshold = 0.15;

typedef DismissDirectionCallback = void Function(DismissDirection direction);

class DismissiblePage extends StatefulWidget {
  DismissiblePage({
    @required this.child,
    this.isFullScreen = true,
    this.disabled = false,
    this.backgroundColor = Colors.black,
    this.direction = DismissDirection.vertical,
    this.dismissThresholds = const <DismissDirection, double>{},
    this.dragStartBehavior = DragStartBehavior.start,
    this.crossAxisEndOffset = 0.0,
    this.minRadius = 7,
    this.minScale = .85,
    this.maxRadius = 30,
    this.maxTransformValue = .4,
    this.onDismiss,
    this.onDragStart,
    this.onDragEnd,
    this.reverseDuration = const Duration(milliseconds: 500),
    Key key,
  })  : assert(dragStartBehavior != null),
        super(key: key);

  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final VoidCallback onDismiss;
  final bool isFullScreen;
  final double minScale;
  final double minRadius;
  final double maxRadius;
  final double maxTransformValue;
  final bool disabled;
  final Widget child;
  final Color backgroundColor;
  final DismissDirection direction;
  final Map<DismissDirection, double> dismissThresholds;
  final double crossAxisEndOffset;
  final DragStartBehavior dragStartBehavior;
  final Duration reverseDuration;

  @override
  _DismissibleState createState() => _DismissibleState();
}

class _DismissibleState extends State<DismissiblePage>
    with TickerProviderStateMixin {
  AnimationController _moveController;
  Animation<Offset> _moveAnimation;
  AnimationController _resizeController;
  double _dragExtent = 0.0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(microseconds: 1),
      vsync: this,
    )..addStatusListener(_handleDismissStatusChanged);
    _updateMoveAnimation();
  }

  @override
  void dispose() {
    _moveController?.removeStatusListener(_handleDismissStatusChanged);
    _moveController?.dispose();
    _resizeController?.dispose();
    super.dispose();
  }

  bool get _directionIsXAxis {
    return widget.direction == DismissDirection.horizontal ||
        widget.direction == DismissDirection.endToStart ||
        widget.direction == DismissDirection.startToEnd;
  }

  DismissDirection _extentToDirection(double extent) {
    if (extent == 0.0) return null;
    if (_directionIsXAxis) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          return extent < 0
              ? DismissDirection.startToEnd
              : DismissDirection.endToStart;
        case TextDirection.ltr:
          return extent > 0
              ? DismissDirection.startToEnd
              : DismissDirection.endToStart;
      }
      assert(false);
      return null;
    }
    return extent > 0 ? DismissDirection.down : DismissDirection.up;
  }

  DismissDirection get _dismissDirection => _extentToDirection(_dragExtent);

  bool get _isActive {
    return _dragUnderway || _moveController.isAnimating;
  }

  double get _overallDragAxisExtent {
    final size = context.size;
    return _directionIsXAxis ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
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
    setState(() => _updateMoveAnimation());
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController.isAnimating || widget.disabled) return;

    final delta = details.primaryDelta;
    final oldDragExtent = _dragExtent;
    bool _(DismissDirection d) => widget.direction == d;

    if (_(DismissDirection.horizontal) || _(DismissDirection.vertical)) {
      _dragExtent += delta;
    } else if (_(DismissDirection.up)) {
      if (_dragExtent + delta < 0) _dragExtent += delta;
    } else if (_(DismissDirection.down)) {
      if (_dragExtent + delta > 0) _dragExtent += delta;
    } else if (_(DismissDirection.endToStart)) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          if (_dragExtent + delta > 0) _dragExtent += delta;
          break;
        default:
          if (_dragExtent + delta < 0) _dragExtent += delta;
      }
    } else if (_(DismissDirection.startToEnd)) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          if (_dragExtent + delta < 0) _dragExtent += delta;
          break;
        default:
          if (_dragExtent + delta > 0) _dragExtent += delta;
      }
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() => _updateMoveAnimation());
    }

    if (!_moveController.isAnimating) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _updateMoveAnimation() {
    _moveAnimation = _moveController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: _directionIsXAxis
            ? Offset(0.7, widget.crossAxisEndOffset)
            : Offset(widget.crossAxisEndOffset, 0.7),
      ),
    );
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (!_isActive || _moveController.isAnimating) return;
    if (!_moveController.isDismissed) {
      if (_moveController.value >
          (widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold)) {
        widget.onDismiss?.call();
      } else {
        _moveController.reverseDuration = widget.reverseDuration;
        _moveController.reverse();
        widget.onDragEnd?.call();
      }
    }
  }

  void _handleDismissStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding =
        widget.isFullScreen ? EdgeInsets.zero : MediaQuery.of(context).padding;

    if (widget.disabled) {
      return Padding(padding: contentPadding, child: widget.child);
    }

    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: widget.dragStartBehavior,
      child: AnimatedBuilder(
        animation: _moveAnimation,
        child: widget.child,
        builder: (BuildContext context, Widget child) {
          final k = _directionIsXAxis
              ? _moveAnimation.value.dx
              : _moveAnimation.value.dy;

          final dx = _moveAnimation.value.dx.clamp(0, widget.maxTransformValue);
          final dy = _moveAnimation.value.dy.clamp(0, widget.maxTransformValue);
          final scale = lerpDouble(1, widget.minScale, k);
          final radius = lerpDouble(widget.minRadius, widget.maxRadius, k);

          return Container(
            padding: contentPadding,
            color: widget.backgroundColor.withOpacity(1 - k),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(dx * _dragExtent, dy * _dragExtent)
                ..scale(scale, scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
