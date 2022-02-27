part of 'dismissible_page.dart';

class MultiAxisDismissiblePage extends StatefulWidget {
  const MultiAxisDismissiblePage({
    required this.child,
    required this.onDismiss,
    required this.isFullScreen,
    required this.disabled,
    required this.backgroundColor,
    required this.direction,
    required this.dismissThresholds,
    required this.dragStartBehavior,
    required this.crossAxisEndOffset,
    required this.dragSensitivity,
    required this.minRadius,
    required this.minScale,
    required this.maxRadius,
    required this.maxTransformValue,
    required this.startingOpacity,
    required this.onDragStart,
    required this.onDragEnd,
    required this.reverseDuration,
    Key? key,
  }) : super(key: key);

  final double startingOpacity;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final VoidCallback onDismiss;
  final bool isFullScreen;
  final double minScale;
  final double minRadius;
  final double maxRadius;
  final double maxTransformValue;
  final bool disabled;
  final Widget child;
  final Color backgroundColor;
  final DismissiblePageDismissDirection direction;
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;
  final double crossAxisEndOffset;
  final double dragSensitivity;
  final DragStartBehavior dragStartBehavior;
  final Duration reverseDuration;

  @protected
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) {
    return ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }

  @override
  _MultiAxisDismissiblePageState createState() =>
      _MultiAxisDismissiblePageState();
}

class _MultiAxisDismissiblePageState extends State<MultiAxisDismissiblePage>
    with Drag, SingleTickerProviderStateMixin {
  late final AnimationController _moveController;
  final _offsetNotifier = ValueNotifier(Offset.zero);
  Offset _startOffset = Offset.zero;
  late final GestureRecognizer _recognizer;
  int _activeCount = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _moveController =
        AnimationController(duration: widget.reverseDuration, vsync: this);
    _moveController.addStatusListener(statusListener);
    _moveController.addListener(animationListener);
    _recognizer = widget.createRecognizer(_startDrag);
  }

  void animationListener() {
    _offsetNotifier.value = Offset.lerp(
      _offsetNotifier.value,
      Offset.zero,
      Curves.easeInOut.transform(_moveController.value),
    )!;
  }

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _moveController.value = 0;
    }
  }

  DismissiblePageDismissDirection _extentToDirection() {
    return DismissiblePageDismissDirection.multi;
  }

  double overallDrag() {
    final size = MediaQuery.of(context).size;
    final distanceOffset = _offsetNotifier.value - Offset.zero;
    final w = distanceOffset.dx.abs() / size.width;
    final h = distanceOffset.dy.abs() / size.height;
    return max(w, h);
  }

  Drag? _startDrag(Offset position) {
    if (_activeCount > 1) return null;
    _dragUnderway = true;
    final renderObject = context.findRenderObject()! as RenderBox;
    _startOffset = renderObject.globalToLocal(position);
    return this;
  }

  void _routePointer(PointerDownEvent event) {
    ++_activeCount;
    if (_activeCount > 1) return;
    _recognizer.addPointer(event);
  }

  @override
  void update(DragUpdateDetails details) {
    if (_activeCount > 1) return;
    _offsetNotifier.value = details.globalPosition - _startOffset;
  }

  @override
  void cancel() => _dragUnderway = false;

  @override
  void end(DragEndDetails details) {
    if (!_dragUnderway) return;
    _dragUnderway = false;
    final shouldDismiss = overallDrag() >
        (widget.dismissThresholds[_extentToDirection()] ?? _kDismissThreshold);
    if (shouldDismiss) {
      widget.onDismiss();
    } else {
      _moveController.animateTo(1);
    }
  }

  void _disposeRecognizerIfInactive() {
    if (_activeCount > 0) return;
    _recognizer.dispose();
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    _moveController.dispose();
    _offsetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding =
        widget.isFullScreen ? EdgeInsets.zero : MediaQuery.of(context).padding;

    final content = ValueListenableBuilder<Offset>(
      valueListenable: _offsetNotifier,
      child: widget.child,
      builder: (_, Offset offset, Widget? child) {
        final k = overallDrag();
        final scale = lerpDouble(1, widget.minScale, k);
        final radius = lerpDouble(widget.minRadius, widget.maxRadius, k)!;
        final opacity = (widget.startingOpacity - k).clamp(.0, 1.0);

        return Container(
          padding: contentPadding,
          color: widget.backgroundColor.withOpacity(opacity),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(offset.dx, offset.dy)
              ..scale(scale, scale),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: child,
            ),
          ),
        );
      },
    );

    return Listener(
      onPointerDown: _routePointer,
      onPointerUp: (_) => --_activeCount,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
