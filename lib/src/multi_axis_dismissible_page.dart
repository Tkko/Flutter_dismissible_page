part of 'dismissible_page.dart';

@visibleForTesting
class MultiAxisDismissiblePage extends StatefulWidget {
  const MultiAxisDismissiblePage({
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
    with SingleTickerProviderStateMixin, _DismissiblePageMixin
    implements Drag {
  late final GestureRecognizer _recognizer;
  late final ValueNotifier<DismissiblePageDragUpdateDetails> _dragNotifier;
  Offset _startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    final initialDetails = DismissiblePageDragUpdateDetails(
      radius: widget.minRadius,
      opacity: widget.startingOpacity,
    );
    _dragNotifier = ValueNotifier(initialDetails);
    _moveController =
        AnimationController(duration: widget.reverseDuration, vsync: this);
    _moveController
      ..addStatusListener(statusListener)
      ..addListener(animationListener);
    _recognizer = widget.createRecognizer(_startDrag);
    _dragNotifier.addListener(_dragListener);
  }

  void animationListener() {
    final offset = Offset.lerp(
      _dragNotifier.value.offset,
      Offset.zero,
      Curves.easeInOut.transform(_moveController.value),
    )!;
    _updateOffset(offset);
  }

  void _updateOffset(Offset offset) {
    final k = overallDrag(offset);
    _dragNotifier.value = DismissiblePageDragUpdateDetails(
      offset: offset,
      overallDragValue: k,
      radius: lerpDouble(widget.minRadius, widget.maxRadius, k)!,
      opacity: (widget.startingOpacity - k).clamp(.0, 1.0),
      scale: lerpDouble(1, widget.minScale, k)!,
    );
  }

  void _dragListener() {
    widget.onDragUpdate?.call(_dragNotifier.value);
  }

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _moveController.value = 0;
    }
  }

  double overallDrag([Offset? nullableOffset]) {
    final offset = nullableOffset ?? _dragNotifier.value.offset;
    final size = MediaQuery.of(context).size;
    final distanceOffset = offset - Offset.zero;
    final w = distanceOffset.dx.abs() / size.width;
    final h = distanceOffset.dy.abs() / size.height;
    return max(w, h);
  }

  Drag? _startDrag(Offset position) {
    if (_activePointerCount > 1) return null;
    _dragUnderway = true;
    final renderObject = context.findRenderObject()! as RenderBox;
    _startOffset = renderObject.globalToLocal(position);
    return this;
  }

  void _routePointer(PointerDownEvent event) {
    if (_activePointerCount > 1) return;
    _recognizer.addPointer(event);
  }

  @override
  void update(DragUpdateDetails details) {
    if (_activePointerCount > 1) return;
    _updateOffset(
      (details.globalPosition - _startOffset) * widget.dragSensitivity,
    );
  }

  @override
  void cancel() => _dragUnderway = false;

  @override
  void end(DragEndDetails _) {
    if (!_dragUnderway) return;
    _dragUnderway = false;
    final shouldDismiss = overallDrag() >
        (widget.dismissThresholds[DismissiblePageDismissDirection.multi] ??
            _kDismissThreshold);
    if (shouldDismiss) {
      widget.onDismissed();
    } else {
      _moveController.animateTo(1);
    }
  }

  void _disposeRecognizerIfInactive() {
    if (_activePointerCount > 0) return;
    _recognizer.dispose();
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    _moveController.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DismissiblePageListener(
      parentState: this,
      onStart: _startDrag,
      onUpdate: update,
      onEnd: end,
      onPointerDown: _routePointer,
      direction: widget.direction,
      child: ValueListenableBuilder<DismissiblePageDragUpdateDetails>(
        valueListenable: _dragNotifier,
        child: widget.child,
        builder: (_, details, Widget? child) {
          final backgroundColor = widget.backgroundColor == Colors.transparent
              ? Colors.transparent
              : widget.backgroundColor.withOpacity(details.opacity);

          return Container(
            padding: widget.contentPadding,
            color: backgroundColor,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(details.offset.dx, details.offset.dy)
                ..scale(details.scale, details.scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(details.radius),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
