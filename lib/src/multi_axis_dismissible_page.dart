// ignore_for_file: deprecated_member_use

part of 'dismissible_page.dart';

/// {@template multi_axis_dismissible_page}
/// A specialized implementation of [DismissiblePage] that handles
/// multi-directional dismissal gestures.
///
/// This widget allows users to dismiss content by dragging in any direction
/// (horizontal or vertical). It provides smooth animations, gesture
/// recognition, and integration with scrollable widgets.
///
/// The widget supports two interaction modes:
/// - [DismissiblePageInteractionMode.gesture]: Direct gesture handling
/// - [DismissiblePageInteractionMode.scroll]: Integration with scroll
/// controllers
///
/// Key features:
/// - Multi-directional drag detection
/// - Animated transformations (scale, radius, opacity)
/// - Scroll-aware gesture handling
/// - Customizable dismiss thresholds
/// - Smooth return animations when dismissal threshold is not met
/// {@endtemplate}
@visibleForTesting
class MultiAxisDismissiblePage extends StatefulWidget {
  /// {@macro multi_axis_dismissible_page}
  const MultiAxisDismissiblePage({
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

  /// Creates a multi-drag gesture recognizer for handling simultaneous
  /// gestures.
  @protected
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) {
    return ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }

  @override
  State<MultiAxisDismissiblePage> createState() =>
      _MultiAxisDismissiblePageState();
}

class _MultiAxisDismissiblePageState extends State<MultiAxisDismissiblePage>
    with SingleTickerProviderStateMixin, _DismissiblePageMixin
    implements Drag {
  /// The gesture recognizer for handling multi-directional drags.
  late final GestureRecognizer _recognizer;

  /// Notifier for drag update details, used to trigger UI rebuilds.
  late final ValueNotifier<DismissiblePageDragUpdateDetails> _dragNotifier;

  /// Custom scroll controller for scroll-aware dismissal mode.
  late final _DismissiblePageScrollController _scrollController;

  /// Default scroll controller for gesture-only mode.
  late final ScrollController _defaultScrollController;

  /// The initial touch position when a drag gesture starts.
  Offset _startOffset = Offset.zero;

  /// The accumulated offset from scroll-based drag operations.
  Offset _scrollDragOffset = Offset.zero;

  /// The screen size, used for calculating drag percentages.
  late final Size _screenSize = MediaQuery.sizeOf(context);

  @override
  void initState() {
    super.initState();
    final initialDetails = DismissiblePageDragUpdateDetails(
      radius: widget.minRadius,
      opacity: widget.startingOpacity,
    );
    _dragNotifier = ValueNotifier(initialDetails);
    _moveController = AnimationController(
      duration: widget.reverseDuration,
      vsync: this,
    );
    _moveController
      ..addStatusListener(statusListener)
      ..addListener(animationListener);
    _recognizer = widget.createRecognizer(_startDrag);
    _scrollController = _DismissiblePageScrollController(
      shouldConsumeUserOffset: _shouldConsumeUserOffset,
      onDismissDragStart: _handleScrollDragStart,
      onDismissDragUpdate: _handleScrollDragUpdate,
      onDismissDragEnd: _handleScrollDragEnd,
    );
    _defaultScrollController = ScrollController();
    _dragNotifier.addListener(_dragListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DismissiblePageDragNotification(
        details: _dragNotifier.value,
      ).dispatch(context);
    }, debugLabel: 'MultiAxisDismissiblePage.dispatchDragNotification');
  }

  /// Animation listener that interpolates the widget back to its original
  /// position.
  void animationListener() {
    final offset = Offset.lerp(
      _dragNotifier.value.offset,
      Offset.zero,
      Curves.easeInOut.transform(_moveController.value),
    )!;
    _updateOffset(offset);
  }

  /// Updates the current drag offset and recalculates all visual properties.
  void _updateOffset(Offset offset) {
    final k = overallDrag(offset);
    _dragNotifier.value = DismissiblePageDragUpdateDetails(
      offset: offset,
      overallDragValue: k,
      radius: lerpDouble(widget.minRadius, widget.maxRadius, k)!,
      opacity: lerpDouble(
        widget.startingOpacity,
        widget.minOpacity,
        k,
      )!.clamp(widget.minOpacity, 1.0),
      scale: lerpDouble(1, widget.minScale, k)!,
    );
  }

  /// Listener for drag updates that forwards changes to the widget's callback.
  void _dragListener() {
    widget.onDragUpdate?.call(_dragNotifier.value);
    DismissiblePageDragNotification(
      details: _dragNotifier.value,
    ).dispatch(context);
  }

  /// Status listener for the animation controller.
  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _moveController.value = 0;
    }
  }

  /// Calculates the overall drag progress as a value between 0.0 and 1.0.
  ///
  /// The progress is determined by the maximum of horizontal and vertical
  /// drag distances relative to the screen dimensions.
  double overallDrag([Offset? nullableOffset]) {
    final offset = nullableOffset ?? _dragNotifier.value.offset;
    final distanceOffset = offset - Offset.zero;
    final w = distanceOffset.dx.abs() / _screenSize.width;
    final h = distanceOffset.dy.abs() / _screenSize.height;
    return max(w, h);
  }

  /// Initiates a drag gesture when the user touches the screen.
  ///
  /// Returns null if multiple pointers are active (multi-touch scenario).
  /// Otherwise, returns this object as the [Drag] handler.
  Drag? _startDrag(Offset position) {
    if (_activePointerCount > 1) return null;
    _dragUnderway = true;
    final renderObject = context.findRenderObject()! as RenderBox;
    _startOffset = renderObject.globalToLocal(position);
    return this;
  }

  /// Routes pointer events to the gesture recognizer.
  void _routePointer(PointerDownEvent event) {
    if (_activePointerCount > 1) return;
    _recognizer.addPointer(event);
  }

  /// Updates the drag position based on user input.
  @override
  void update(DragUpdateDetails details) {
    if (_activePointerCount > 1) return;
    _updateOffset(
      (details.globalPosition - _startOffset) * widget.dragSensitivity,
    );
  }

  /// Cancels the current drag operation.
  @override
  void cancel() => _dragUnderway = false;

  /// Handles the end of a drag gesture.
  @override
  void end(DragEndDetails _) {
    if (!_dragUnderway) return;
    _dragUnderway = false;
    final shouldDismiss =
        overallDrag() >
        (widget.dismissThresholds[DismissiblePageDismissDirection.multi] ??
            _kDismissThreshold);
    if (shouldDismiss) {
      DismissiblePageDragNotification(
        details: _dragNotifier.value.copyWith(isDismissed: true),
      ).dispatch(context);
      widget.onDismissed();
    } else {
      unawaited(_moveController.animateTo(1));
      DismissiblePageDragNotification(
        details: _dragNotifier.value,
      ).dispatch(context);
      widget.onDragEnd?.call();
    }
  }

  /// Disposes the gesture recognizer if no pointers are active.
  void _disposeRecognizerIfInactive() {
    if (_activePointerCount > 0) return;
    _recognizer.dispose();
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    _scrollController.dispose();
    _defaultScrollController.dispose();
    _moveController.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  /// Handles the start of a scroll-based drag operation.
  void _handleScrollDragStart() {
    _dragUnderway = true;
    _scrollDragOffset = _dragNotifier.value.offset;
    widget.onDragStart?.call();
  }

  /// Updates the drag offset during scroll-based drag operations.
  void _handleScrollDragUpdate(
    double delta,
    ScrollPosition position,
  ) {
    final axis = axisDirectionToAxis(position.axisDirection);
    final scaledDelta = delta * widget.dragSensitivity;
    if (axis == Axis.horizontal) {
      _scrollDragOffset = Offset(
        _scrollDragOffset.dx + scaledDelta,
        _scrollDragOffset.dy,
      );
    } else {
      _scrollDragOffset = Offset(
        _scrollDragOffset.dx,
        _scrollDragOffset.dy + scaledDelta,
      );
    }
    _updateOffset(_scrollDragOffset);
  }

  /// Handles the end of a scroll-based drag operation.
  ///
  /// Similar to [end], but specifically for scroll-initiated drags.
  /// Checks dismissal threshold and either dismisses or returns to origin.
  void _handleScrollDragEnd() {
    // _dragUnderway = false;
    // final shouldDismiss =
    //     overallDrag() >
    //     (widget.dismissThresholds[DismissiblePageDismissDirection.multi] ??
    //         _kDismissThreshold);
    // if (shouldDismiss) {
    //   widget.onDismissed();
    //   return;
    // }
    // widget.onDragEnd?.call();
    // unawaited(_moveController.animateTo(1));
  }

  /// Determines whether the scroll controller should consume user scroll input.
  ///
  /// Returns true if the scroll input should be consumed for dismissal,
  /// false if it should be handled by the scroll view.
  bool _shouldConsumeUserOffset(double delta, ScrollPosition position) {
    final motionDelta = delta;
    if (widget.direction != DismissiblePageDismissDirection.multi) {
      return false;
    }
    final atMinExtent = position.pixels <= position.minScrollExtent;
    final atMaxExtent = position.pixels >= position.maxScrollExtent;
    final axis = axisDirectionToAxis(position.axisDirection);
    final currentOffset = _dragNotifier.value.offset;

    final dragExtent = axis == Axis.horizontal
        ? currentOffset.dx
        : currentOffset.dy;

    final isReturningToOrigin =
        (dragExtent > 0 && motionDelta < 0) ||
        (dragExtent < 0 && motionDelta > 0);
    if (dragExtent != 0 && isReturningToOrigin) {
      return true;
    }

    if (dragExtent != 0) {
      return true;
    }

    return motionDelta > 0 ? atMinExtent : atMaxExtent;
  }

  @override
  Widget build(BuildContext context) {
    final scrollController =
        widget.interactionMode == DismissiblePageInteractionMode.scroll
        ? _scrollController
        : _defaultScrollController;
    final content = ValueListenableBuilder<DismissiblePageDragUpdateDetails>(
      valueListenable: _dragNotifier,
      child: widget.builder(context, scrollController),
      builder: (_, details, child) {
        dev.log('details.opacity: ${details.opacity}');
        final backgroundColor = switch ((
          widget.backgroundColor,
          widget.enableBackgroundOpacity,
        )) {
          (final color?, _) when color == Colors.transparent => color,
          (final color?, true) => color.withValues(alpha: details.opacity),
          (final color, _) => color,
        };

        Widget content = Transform(
          transform: Matrix4.identity()
            ..translate(details.offset.dx, details.offset.dy)
            ..scale(details.scale, details.scale),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(details.radius)),
            child: child,
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
    );

    // if (widget.interactionMode == DismissiblePageInteractionMode.scroll) {
    //   return content;
    // }

    /// Explicitly handle both gesture and scroll modes, because otherwise
    /// scroll can't target multi-axis.
    ///
    /// So, in the multi-axis mode the [scrollController] is used to not scroll
    /// the scrollable widget inside the [builder], when the page is dragging.
    ///
    /// Thought, Scroll controller still dispatches the updates to the offset
    /// when is being scrolled normally.
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          DismissiblePageDragNotification(
            details: _dragNotifier.value.copyWith(isDismissed: true),
          ).dispatch(context);
        }
      },
      child: _DismissiblePageListener(
        parentState: this,
        onStart: _startDrag,
        onUpdate: update,
        onEnd: end,
        onPointerDown: _routePointer,
        direction: widget.direction,
        enabled: !widget.disabled,
        child: content,
      ),
    );
  }
}
