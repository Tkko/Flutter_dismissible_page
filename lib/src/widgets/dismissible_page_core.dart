part of '../dismissible_page.dart';

class _DismissiblePageCore extends StatefulWidget {
  const _DismissiblePageCore({
    required this.contentBuilder,
    required this.enabled,
    required this.onDismissed,
    required this.isFullScreen,
    required this.background,
    required this.borderRadius,
    required this.direction,
    required this.dismissThresholds,
    required this.dragSensitivity,
    required this.minScale,
    required this.maxTransformValue,
    required this.dragStartBehavior,
    required this.reverseDuration,
    required this.hitTestBehavior,
    required this.contentPadding,
    this.controller,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
  });

  final Widget Function(
    BuildContext context,
    DismissiblePageScrollController controller,
  ) contentBuilder;
  final DismissiblePageScrollController? controller;
  final VoidCallback onDismissed;
  final bool enabled;
  final bool isFullScreen;
  final DismissiblePageBackground background;
  final DismissiblePageRadius borderRadius;
  final DismissiblePageDismissDirection direction;
  final Map<DismissiblePageSide, double> dismissThresholds;
  final double dragSensitivity;
  final double minScale;
  final double maxTransformValue;
  final DragStartBehavior dragStartBehavior;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDragCancel;
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;
  final Duration reverseDuration;
  final HitTestBehavior hitTestBehavior;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<_DismissiblePageCore> createState() => _DismissiblePageCoreState();
}

class _DismissiblePageCoreState extends State<_DismissiblePageCore>
    with TickerProviderStateMixin {
  late _DismissibleArbiter _arbiter;
  DismissiblePageScrollController? _internalController;

  // Keeps the content subtree (and its scroll state) alive when [enabled]
  // flips and the wrapper structure around it changes.
  final GlobalKey _contentKey = GlobalKey();

  DismissiblePageScrollController get _effectiveController =>
      widget.controller ??
      (_internalController ??= DismissiblePageScrollController());

  @override
  void initState() {
    super.initState();
    _initArbiter();
    _effectiveController._arbiter = widget.enabled ? _arbiter : null;
  }

  @override
  void didUpdateWidget(_DismissiblePageCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    _arbiter.updateCallbacks(
      onDismissed: widget.onDismissed,
      onDragStart: widget.onDragStart,
      onDragEnd: widget.onDragEnd,
      onDragCancel: widget.onDragCancel,
      onDragUpdate: widget.onDragUpdate,
    );
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?._arbiter = null;
    }
    _arbiter.updateConfig(
      direction: widget.direction,
      dismissThresholds: widget.dismissThresholds,
      background: widget.background,
      borderRadius: widget.borderRadius,
      minScale: widget.minScale,
      maxTransformValue: widget.maxTransformValue,
      dragSensitivity: widget.dragSensitivity,
      reverseDuration: widget.reverseDuration,
    );
    if (oldWidget.enabled && !widget.enabled) {
      // Callbacks must not run mid-build, so settle the page after this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.enabled) _arbiter.reset();
      });
    }
    _effectiveController._arbiter = widget.enabled ? _arbiter : null;
  }

  void _initArbiter() {
    _arbiter = _DismissibleArbiter(
      direction: widget.direction,
      dismissThresholds: widget.dismissThresholds,
      background: widget.background,
      borderRadius: widget.borderRadius,
      minScale: widget.minScale,
      maxTransformValue: widget.maxTransformValue,
      dragSensitivity: widget.dragSensitivity,
      reverseDuration: widget.reverseDuration,
      onDismissed: widget.onDismissed,
      onDragStart: widget.onDragStart,
      onDragEnd: widget.onDragEnd,
      onDragCancel: widget.onDragCancel,
      onDragUpdate: widget.onDragUpdate,
      vsync: this,
    );
  }

  @override
  void dispose() {
    (widget.controller ?? _internalController)?._arbiter = null;
    _internalController?.dispose();
    _arbiter.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _arbiter.applyDelta(details.delta);
  }

  double _axisVelocity(Offset pixelsPerSecond) {
    return switch (widget.direction) {
      DismissiblePageDismissDirection.horizontal ||
      DismissiblePageDismissDirection.startToEnd ||
      DismissiblePageDismissDirection.endToStart =>
        pixelsPerSecond.dx,
      DismissiblePageDismissDirection.all =>
        _arbiter.offset.dx.abs() > _arbiter.offset.dy.abs()
            ? pixelsPerSecond.dx
            : pixelsPerSecond.dy,
      _ => pixelsPerSecond.dy,
    };
  }

  void _handlePanEnd(DragEndDetails details) {
    _arbiter.endDrag(velocity: _axisVelocity(details.velocity.pixelsPerSecond));
  }

  // Bouncing scrollables hand over to a spring when the finger lifts, and no
  // notification carries the release velocity, so it is estimated from the
  // deltas applied to the page.
  VelocityTracker _releaseTracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  void _applyScrollDelta(Offset delta, Duration? timeStamp) {
    if (!_arbiter.isDragging) {
      _releaseTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    }
    _arbiter.applyDelta(delta);
    if (timeStamp != null) {
      _releaseTracker.addPosition(timeStamp, _arbiter.offset);
    }
  }

  void _handlePanCancel() {
    _arbiter.cancelDrag();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (widget.direction == DismissiblePageDismissDirection.none) {
      return false;
    }

    if (notification.depth != 0) {
      return false;
    }

    // ScrollPosition managed by DismissiblePageScrollController handles deltas directly.
    if (notification.metrics is _DismissiblePageScrollPosition) {
      return false;
    }

    if (notification is OverscrollNotification) {
      final physicalDelta = _physicalScrollDelta(
        -notification.overscroll,
        notification.metrics.axisDirection,
      );
      final delta = notification.metrics.axis == Axis.vertical
          ? Offset(0, physicalDelta)
          : Offset(physicalDelta, 0);
      if (_arbiter.isDeltaAllowed(delta)) {
        _applyScrollDelta(delta, notification.dragDetails?.sourceTimeStamp);
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final dragDetails = notification.dragDetails;
      if (dragDetails == null) {
        // Movement without a finger is the list's own spring or fling: the
        // finger has lifted. Settle the page now rather than letting the
        // spring drag it back to the origin.
        if (_arbiter.isDragging) {
          _arbiter.endDrag(
            velocity: _axisVelocity(
              _releaseTracker.getVelocity().pixelsPerSecond,
            ),
          );
        }
        return false;
      }

      final isVertical = notification.metrics.axis == Axis.vertical;
      final currentCoord = isVertical ? _arbiter.offset.dy : _arbiter.offset.dx;

      // If page is currently offset, consume reverse scroll back towards origin
      if (currentCoord != 0) {
        final physicalDelta = _physicalScrollDelta(
          -(notification.scrollDelta ?? 0),
          notification.metrics.axisDirection,
        );
        final delta =
            isVertical ? Offset(0, physicalDelta) : Offset(physicalDelta, 0);
        _applyScrollDelta(delta, dragDetails.sourceTimeStamp);
        return false;
      }

      if (notification.metrics.outOfRange) {
        if (_arbiter.isDeltaAllowed(dragDetails.delta)) {
          _applyScrollDelta(dragDetails.delta, dragDetails.sourceTimeStamp);
        }
      }
      return false;
    }

    if (notification is ScrollEndNotification) {
      if (_arbiter.isDragging || _arbiter.isOffsetNonZero) {
        // Fling velocity comes from the drag that ended the scroll, if any.
        final endVelocity = notification.dragDetails?.velocity.pixelsPerSecond;
        _arbiter.endDrag(
          velocity: endVelocity == null ? 0 : _axisVelocity(endVelocity),
        );
      }
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController = _effectiveController;
    final contentWithController = RepaintBoundary(
      key: _contentKey,
      child: PrimaryScrollController(
        controller: effectiveController,
        child: widget.contentBuilder(context, effectiveController),
      ),
    );

    if (!widget.enabled) {
      final initialColor = widget.background.resolveColor(0);
      final initialRadius = widget.borderRadius.resolveRadius(0);
      Widget content = contentWithController;
      if (initialRadius > 0) {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(initialRadius),
          child: content,
        );
      }
      final body = widget.contentPadding == EdgeInsets.zero
          ? content
          : Padding(
              padding: widget.contentPadding,
              child: content,
            );
      return initialColor == null
          ? body
          : ColoredBox(color: initialColor, child: body);
    }

    final hasRadius = !widget.borderRadius.isNone;
    final hasBackground = !widget.background.isNone;

    return LayoutBuilder(
      builder: (context, constraints) {
        _arbiter.updateLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
          Directionality.of(context),
        );

        return NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: GestureDetector(
            behavior: widget.hitTestBehavior,
            dragStartBehavior: widget.dragStartBehavior,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            onPanCancel: _handlePanCancel,
            child: RepaintBoundary(
              child: ListenableBuilder(
                listenable: _arbiter,
                builder: (context, child) {
                  final details = _arbiter.currentDetails;

                  var content = child!;
                  if (hasRadius) {
                    content = ClipRRect(
                      borderRadius: BorderRadius.circular(details.radius),
                      clipBehavior:
                          details.radius > 0 ? Clip.antiAlias : Clip.none,
                      child: content,
                    );
                  }

                  Widget body = Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      details.scale,
                      details.scale,
                      1,
                    )..setTranslationRaw(
                        details.offset.dx,
                        details.offset.dy,
                        0,
                      ),
                    child: content,
                  );

                  if (widget.contentPadding != EdgeInsets.zero) {
                    body = Padding(
                      padding: widget.contentPadding,
                      child: body,
                    );
                  }

                  if (hasBackground) {
                    final bgColor =
                        widget.background.resolveColor(details.progress);
                    if (bgColor != null && bgColor.a > 0) {
                      body = ColoredBox(
                        color: bgColor,
                        child: body,
                      );
                    }
                  }

                  return body;
                },
                child: contentWithController,
              ),
            ),
          ),
        );
      },
    );
  }
}
