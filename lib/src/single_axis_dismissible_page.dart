// ignore_for_file: discarded_futures

part of 'dismissible_page.dart';

/// {@template single_axis_dismissible_page}
/// A specialized implementation of [DismissiblePage] that handles
/// single-directional dismissal gestures.
///
/// This widget allows users to dismiss content by dragging in a specific
/// direction (horizontal, vertical, or constrained directional). It provides
/// smooth animations, gesture recognition, and integration with scrollable
/// widgets.
///
/// The widget supports two interaction modes:
/// - [DismissiblePageInteractionMode.gesture]: Direct gesture handling
/// - [DismissiblePageInteractionMode.scroll]: Integration with scroll
/// controllers
///
/// Key features:
/// - Single-direction drag detection with directional constraints
/// - Animated transformations (scale, radius, opacity, translation)
/// - Scroll-aware gesture handling with proper coordination
/// - Customizable dismiss thresholds per direction
/// - Smooth return animations when dismissal threshold is not met
/// - RTL text direction support for horizontal gestures
/// {@endtemplate}
@visibleForTesting
class SingleAxisDismissiblePage extends StatefulWidget {
  /// {@macro single_axis_dismissible_page}
  const SingleAxisDismissiblePage({
    required this.builder,
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
    required this.interactionMode,
    required this.enableBackgroundOpacity,
    required this.minOpacity,
    this.disabled = false,
    super.key,
  });

  /// The initial opacity of the background when the page is displayed.
  final double startingOpacity;

  /// Called when the user starts dragging the widget.
  final VoidCallback? onDragStart;

  /// Called when the user ends dragging the widget.
  final VoidCallback? onDragEnd;

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Called when the widget has been dragged with updated details.
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  /// Whether the widget should ignore device padding.
  final bool isFullScreen;

  /// If true, drag-to-dismiss gestures are disabled (content remains
  /// interactive).
  final bool disabled;

  /// The minimum scale factor applied during drag gestures.
  final double minScale;

  /// The minimum border radius of the widget.
  final double minRadius;

  /// The maximum border radius applied during drag gestures.
  final double maxRadius;

  /// The maximum transform value for drag distance (0.0 - 1.0).
  final double maxTransformValue;

  /// Builder function that creates the dismissible content.
  final DismissiblePageBuilder builder;

  /// The background color of the dismissible page.
  final Color? backgroundColor;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// Custom dismiss thresholds for different directions.
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;

  /// Controls the responsiveness of drag gestures.
  final double dragSensitivity;

  /// Determines how drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// Duration for the return animation when dismissal threshold is not met.
  final Duration reverseDuration;

  /// How the widget behaves during hit tests.
  final HitTestBehavior hitTestBehavior;

  /// Padding applied to the content area.
  final EdgeInsetsGeometry contentPadding;

  /// Controls how drag-to-dismiss interaction is coordinated with scrollables.
  final DismissiblePageInteractionMode interactionMode;

  /// Whether to enable background opacity animation.
  final bool enableBackgroundOpacity;

  /// The minimum opacity of the background when the page is displayed.
  final double minOpacity;

  @override
  State<SingleAxisDismissiblePage> createState() =>
      _SingleAxisDismissiblePageState();
}

class _SingleAxisDismissiblePageState extends State<SingleAxisDismissiblePage>
    with TickerProviderStateMixin, _DismissiblePageMixin {
  static const double _kOriginEpsilon = 1e-6;

  /// Animation that controls the movement offset during drag gestures.
  late Animation<Offset> _moveAnimation;

  /// Custom scroll controller for scroll-aware dismissal mode.
  late final _DismissiblePageScrollController _scrollController;

  /// Default scroll controller for gesture-only mode.
  late final ScrollController _defaultScrollController;

  /// The current drag extent in the primary axis direction.
  double _dragExtent = 0;

  /// The text direction of the current context, used for RTL support.
  late final TextDirection _textDirection = Directionality.of(context);

  /// The screen size, used for calculating drag percentages.
  late final Size _screenSize = MediaQuery.sizeOf(context);

  bool _canInnerContentScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = _DismissiblePageScrollController(
      shouldConsumeUserOffset: _shouldConsumeUserOffset,
      onDismissDragStart: _handleScrollDragStart,
      onDismissDragUpdate: _handleScrollDragUpdate,
      onDismissDragEnd: _handleScrollDragEnd,
    );
    _defaultScrollController = ScrollController();
    _moveController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    _moveController
      ..addStatusListener(_handleDismissStatusChanged)
      ..addListener(_moveAnimationListener);
    _updateMoveAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCanInnerContentScroll();
      DismissiblePageDragNotification(details: _details).dispatch(context);
    }, debugLabel: 'SingleAxisDismissiblePage.checkCanInnerContentScroll');
  }

  void _checkCanInnerContentScroll() {
    if (!_scrollController.hasClients) return;

    final oldCanInnerContentScroll = _canInnerContentScroll;
    _canInnerContentScroll = _scrollController.position.maxScrollExtent > 0;

    if (oldCanInnerContentScroll == _canInnerContentScroll) return;

    setState(() {});
  }

  DismissiblePageDragUpdateDetails get _details =>
      DismissiblePageDragUpdateDetails(
        overallDragValue: min(
          _dragExtent / _overallDragAxisExtent,
          widget.maxTransformValue,
        ),
        radius: _radius,
        opacity: _opacity,
        offset: _offset,
        scale: _scale ?? 0.0,
      );

  /// Animation listener that triggers drag update callbacks.
  void _moveAnimationListener() {
    if (widget.onDragUpdate case final onDragUpdate?) {
      onDragUpdate.call(_details);
    }

    DismissiblePageDragNotification(details: _details).dispatch(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _defaultScrollController.dispose();
    _moveController
      ..removeStatusListener(_handleDismissStatusChanged)
      ..removeListener(_moveAnimationListener)
      ..dispose();
    super.dispose();
  }

  /// Returns true if the scroll delta can be converted to a drag delta.
  bool get _canConvertScrollDeltaToDragDelta =>
      widget.direction.axes.contains(Axis.vertical) &&
      widget.interactionMode == DismissiblePageInteractionMode.scroll;

  /// Returns true if the configured direction is along the X-axis.
  bool get _directionIsXAxis {
    return widget.direction.axes.contains(Axis.horizontal);
  }

  /// Converts a drag extent to its corresponding dismiss direction.
  ///
  /// Takes into account the text direction for horizontal gestures to
  /// properly handle RTL layouts.
  ///
  /// [extent] - The drag extent value to convert.
  ///
  /// Returns the corresponding dismiss direction, or null if extent is zero.
  DismissiblePageDismissDirection? _extentToDirection(double extent) {
    if (extent == 0.0) return null;
    if (_directionIsXAxis) {
      switch (_textDirection) {
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

  /// The current dismiss direction based on the drag extent.
  DismissiblePageDismissDirection? get _dismissDirection =>
      _extentToDirection(_dragExtent);

  /// The total extent of the drag axis (width for horizontal, height for
  /// vertical).
  double get _overallDragAxisExtent {
    return _directionIsXAxis ? _screenSize.width : _screenSize.height;
  }

  /// Handles the start of a drag gesture.
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
    _updateMoveAnimation();
  }

  /// Handles drag update events from gesture recognizers.
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController.isAnimating) return;
    final delta = details.primaryDelta;
    if (delta == null) return;
    _applyDragDelta(delta);
  }

  /// Applies a drag delta to the current drag extent.
  void _applyDragDelta(double delta, {bool isScrollDelta = false}) {
    if (!_isActive || _moveController.isAnimating) return;
    final oldDragExtent = _dragExtent;

    if (isScrollDelta && !_canConvertScrollDeltaToDragDelta) {
      return;
    }

    switch (widget.direction) {
      case DismissiblePageDismissDirection.horizontal:
      case DismissiblePageDismissDirection.vertical:
        _dragExtent += delta;
      case DismissiblePageDismissDirection.up:
        if (_dragExtent + delta < 0) _dragExtent += delta;
      case DismissiblePageDismissDirection.down:
        if (_dragExtent + delta > 0) _dragExtent += delta;
      case DismissiblePageDismissDirection.endToStart:
        switch (_textDirection) {
          case TextDirection.rtl:
            if (_dragExtent + delta > 0) _dragExtent += delta;
          case TextDirection.ltr:
            if (_dragExtent + delta < 0) _dragExtent += delta;
        }
      case DismissiblePageDismissDirection.startToEnd:
        switch (_textDirection) {
          case TextDirection.rtl:
            if (_dragExtent + delta < 0) _dragExtent += delta;
          case TextDirection.ltr:
            if (_dragExtent + delta > 0) _dragExtent += delta;
        }
      case DismissiblePageDismissDirection.multi ||
          DismissiblePageDismissDirection.none:
        // Multi-axis is handled by MultiAxisDismissiblePage
        break;
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      _updateMoveAnimation();
    }

    if (!_moveController.isAnimating) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  /// Updates the move animation based on the current drag extent and direction.
  void _updateMoveAnimation() {
    final end = _dragExtent.sign * widget.dragSensitivity;
    _moveAnimation = _moveController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: _directionIsXAxis ? Offset(end, 0) : Offset(0, end),
      ),
    );
  }

  /// The dismiss threshold for the current dismiss direction.
  double get _dismissThreshold =>
      widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold;

  /// Handles the end of a drag gesture.
  void _handleDragEnd([DragEndDetails? _]) {
    if (!_isActive || _moveController.isAnimating) return;
    _dragUnderway = false;
    if (!_moveController.isDismissed) {
      if (_moveController.value > _dismissThreshold) {
        DismissiblePageDragNotification(
          details: _details.copyWith(isDismissed: true),
        ).dispatch(context);
        widget.onDismissed.call();
      } else {
        _moveController
          ..reverseDuration =
              widget.reverseDuration * (1 / _moveController.value)
          ..reverse();
        DismissiblePageDragNotification(
          details: _details,
        ).dispatch(context);
        widget.onDragEnd?.call();
      }
    }
  }

  /// Handles the start of a scroll-based drag operation.
  void _handleScrollDragStart() {
    _handleDragStart();
  }

  /// Handles scroll-based drag updates.
  void _handleScrollDragUpdate(
    double delta,
    ScrollPosition position,
  ) {
    final hasScrollableContent =
        (position.maxScrollExtent - position.minScrollExtent).abs() >
        _kOriginEpsilon;
    final isReturningToOrigin =
        _dragExtent != 0 && _isDeltaReturningPageToOrigin(delta);
    final reachesOrCrossesOrigin =
        isReturningToOrigin &&
        (delta.abs() + _kOriginEpsilon >= _dragExtent.abs());

    if (hasScrollableContent && reachesOrCrossesOrigin) {
      _dragExtent = 0;
      _moveController.value = 0;
      _updateMoveAnimation();
      return;
    }

    _applyDragDelta(delta, isScrollDelta: true);
  }

  /// Handles the end of a scroll-based drag operation.
  void _handleScrollDragEnd() {
    _handleDragEnd();
  }

  /// Determines if a delta is allowed for the configured direction.
  ///
  /// This method enforces directional constraints, ensuring that drag
  /// gestures only proceed in the allowed direction(s).
  bool _isDeltaAllowedForDirection(double delta) {
    return switch (widget.direction) {
      DismissiblePageDismissDirection.horizontal ||
      DismissiblePageDismissDirection.vertical => true,
      DismissiblePageDismissDirection.up => delta < 0,
      DismissiblePageDismissDirection.down => delta > 0,
      DismissiblePageDismissDirection.endToStart => switch (_textDirection) {
        TextDirection.rtl => delta > 0,
        TextDirection.ltr => delta < 0,
      },
      DismissiblePageDismissDirection.startToEnd => switch (_textDirection) {
        TextDirection.rtl => delta < 0,
        TextDirection.ltr => delta > 0,
      },
      _ => false,
    };
  }

  /// Determines if a delta is returning the page toward its origin.
  ///
  /// This is used to ensure smooth gesture coordination when the user
  /// reverses direction during a drag operation.
  bool _isDeltaReturningPageToOrigin(double delta) {
    return (_dragExtent > 0 && delta < 0) || (_dragExtent < 0 && delta > 0);
  }

  /// Determines whether the scroll controller should consume user scroll input.
  ///
  /// Returns true if the scroll input should be consumed for dismissal,
  /// false if it should be handled by the scroll view.
  bool _shouldConsumeUserOffset(double delta, ScrollPosition position) {
    final motionDelta = delta;
    if (widget.direction == DismissiblePageDismissDirection.none ||
        widget.direction == DismissiblePageDismissDirection.multi) {
      return false;
    }

    // Keep consuming while the page is returning toward origin so content does
    // not start scrolling prematurely.
    final isReturningToOrigin = _isDeltaReturningPageToOrigin(motionDelta);
    if (_dragExtent != 0 && isReturningToOrigin) {
      return true;
    }

    if (!_isDeltaAllowedForDirection(motionDelta)) {
      return false;
    }

    if (_dragExtent != 0 &&
        widget.interactionMode == DismissiblePageInteractionMode.gesture) {
      return true;
    }

    final isAtMinExtent = position.pixels <= position.minScrollExtent;
    final isAtMaxExtent = position.pixels >= position.maxScrollExtent;
    final isRtl = _textDirection == TextDirection.rtl;

    switch (widget.direction) {
      case DismissiblePageDismissDirection.vertical:
      case DismissiblePageDismissDirection.horizontal:
        return motionDelta > 0 ? isAtMinExtent : isAtMaxExtent;
      case DismissiblePageDismissDirection.up:
        return motionDelta < 0 && isAtMaxExtent;
      case DismissiblePageDismissDirection.down:
        return motionDelta > 0 && isAtMinExtent;
      case DismissiblePageDismissDirection.endToStart:
        return isRtl
            ? (motionDelta > 0 && isAtMinExtent)
            : (motionDelta < 0 && isAtMaxExtent);
      case DismissiblePageDismissDirection.startToEnd:
        return isRtl
            ? (motionDelta < 0 && isAtMaxExtent)
            : (motionDelta > 0 && isAtMinExtent);
      case DismissiblePageDismissDirection.none:
      case DismissiblePageDismissDirection.multi:
        return false;
    }
  }

  /// Handles animation status changes for the dismiss animation.
  void _handleDismissStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      DismissiblePageDragNotification(
        details: _details.copyWith(isDismissed: true),
      ).dispatch(context);
      widget.onDismissed();
    }
  }

  /// The current drag value as an absolute value between 0.0 and 1.0.
  double get _dragValue => _directionIsXAxis
      ? _moveAnimation.value.dx.abs()
      : _moveAnimation.value.dy.abs();

  /// The X component of the drag offset, clamped to maxTransformValue.
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

  /// The Y component of the drag offset, clamped to maxTransformValue.
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

  /// The current offset for the transform, combining X and Y components.
  Offset get _offset => Offset(_getDx, _getDy);

  /// The current scale factor, interpolated based on drag progress.
  double? get _scale => lerpDouble(1, widget.minScale, _dragValue);

  /// The current border radius, interpolated based on drag progress.
  double get _radius =>
      lerpDouble(widget.minRadius, widget.maxRadius, _dragValue)!;

  /// The current opacity, calculated based on drag progress.
  double get _opacity => lerpDouble(
    widget.startingOpacity,
    widget.minOpacity,
    _dragValue,
  )!.clamp(widget.minOpacity, 1.0);

  @override
  Widget build(BuildContext context) {
    final scrollController =
        widget.interactionMode == DismissiblePageInteractionMode.scroll
        ? _scrollController
        : _defaultScrollController;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          DismissiblePageDragNotification(
            details: _details.copyWith(isDismissed: true),
          ).dispatch(context);
        }
      },
      child: () {
        final animatedChild = AnimatedBuilder(
          animation: _moveAnimation,
          builder: (context, child) {
            final backgroundColor = switch ((
              widget.backgroundColor,
              widget.enableBackgroundOpacity,
            )) {
              (final color?, _) when color == Colors.transparent => color,
              (final color?, true) => color.withValues(alpha: _opacity),
              (final color, _) => color,
            };

            Widget content = FractionalTranslation(
              translation: _offset,
              child: Transform.scale(
                scale: _scale ?? 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(_radius)),
                  child: child,
                ),
              ),
            );

            if (backgroundColor case final backgroundColor?) {
              content = ColoredBox(color: backgroundColor, child: content);
            }

            return Padding(
              padding: widget.contentPadding,
              child: content,
            );
          },
          child: widget.builder(context, scrollController),
        );

        if (widget.interactionMode == DismissiblePageInteractionMode.scroll &&
            _canInnerContentScroll &&
            _canConvertScrollDeltaToDragDelta) {
          return animatedChild;
        }

        return GestureDetector(
          onHorizontalDragStart: (_directionIsXAxis && !widget.disabled)
              ? _handleDragStart
              : null,
          onHorizontalDragUpdate: (_directionIsXAxis && !widget.disabled)
              ? _handleDragUpdate
              : null,
          onHorizontalDragEnd: (_directionIsXAxis && !widget.disabled)
              ? _handleDragEnd
              : null,
          onVerticalDragStart: (!_directionIsXAxis && !widget.disabled)
              ? _handleDragStart
              : null,
          onVerticalDragUpdate: (!_directionIsXAxis && !widget.disabled)
              ? _handleDragUpdate
              : null,
          onVerticalDragEnd: (!_directionIsXAxis && !widget.disabled)
              ? _handleDragEnd
              : null,
          behavior: widget.hitTestBehavior,
          dragStartBehavior: widget.dragStartBehavior,
          child: _DismissiblePageListener(
            onStart: (_) => _handleDragStart(),
            onUpdate: _handleDragUpdate,
            onEnd: _handleDragEnd,
            parentState: this,
            direction: widget.direction,
            enabled: !widget.disabled,
            child: animatedChild,
          ),
        );
      }(),
    );
  }
}
