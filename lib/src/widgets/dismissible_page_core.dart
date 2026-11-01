part of '../dismissible_page.dart';

bool _sameDismissThresholds(
  Map<DismissiblePageSide, double> first,
  Map<DismissiblePageSide, double> second,
) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  return first.entries.every((entry) => second[entry.key] == entry.value);
}

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
    if (widget.enabled != oldWidget.enabled ||
        widget.direction != oldWidget.direction ||
        !_sameDismissThresholds(
          widget.dismissThresholds,
          oldWidget.dismissThresholds,
        ) ||
        widget.dragSensitivity != oldWidget.dragSensitivity ||
        widget.background != oldWidget.background ||
        widget.borderRadius != oldWidget.borderRadius ||
        widget.minScale != oldWidget.minScale ||
        widget.maxTransformValue != oldWidget.maxTransformValue ||
        widget.reverseDuration != oldWidget.reverseDuration) {
      _arbiter.dispose();
      _initArbiter();
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
    _effectiveController._arbiter = null;
    _internalController?.dispose();
    _arbiter.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _arbiter.applyDelta(details.delta);
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = switch (widget.direction) {
      DismissiblePageDismissDirection.horizontal ||
      DismissiblePageDismissDirection.startToEnd ||
      DismissiblePageDismissDirection.endToStart =>
        details.velocity.pixelsPerSecond.dx,
      DismissiblePageDismissDirection.all =>
        _arbiter.offset.dx.abs() > _arbiter.offset.dy.abs()
            ? details.velocity.pixelsPerSecond.dx
            : details.velocity.pixelsPerSecond.dy,
      _ => details.velocity.pixelsPerSecond.dy,
    };
    _arbiter.endDrag(velocity: velocity);
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
        _arbiter.applyDelta(delta);
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
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
        _arbiter.applyDelta(delta);
        return false;
      }

      if (notification.metrics.outOfRange) {
        final dragDetails = notification.dragDetails;
        if (dragDetails != null && _arbiter.isDeltaAllowed(dragDetails.delta)) {
          _arbiter.applyDelta(dragDetails.delta);
        }
      }
      return false;
    }

    if (notification is ScrollEndNotification) {
      if (_arbiter.isOffsetNonZero) {
        _arbiter.endDrag();
      }
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveController = _effectiveController;
    final contentWithController = RepaintBoundary(
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
