import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:flutter/material.dart';

/// A scenario demonstrating how to coordinate [DismissiblePage] with Flutter's
/// built-in [InteractiveViewer] for pinch-to-zoom, pan, and pull-down-to-dismiss.
class ZoomableImagePage extends StatelessWidget {
  const ZoomableImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final photo = demoPhotos[1];

    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.down,
      // Use the recommended dragRegion so InteractiveViewer receives all pinches/pans:
      gesture: const DismissiblePageGesture(
        dragRegion: DismissibleInteractiveViewer.dragRegion,
      ),
      background: const DismissiblePageBackground.transition(
        from: Colors.black87,
        to: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const DismissibleBackButton(),
          title: const Text(
            'InteractiveViewer Zoom',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        // The actual content widget is cleanly separated and passed to DismissibleInteractiveViewer:
        body: DismissibleInteractiveViewer(
          child: Hero(
            tag: photo.url,
            child: DemoImage(photo.url),
          ),
        ),
      ),
    );
  }
}

/// A reusable widget that enables pinch-to-zoom, pan, and double-tap zoom for its [child],
/// seamlessly bridging with a parent [DismissiblePage] for pull-to-dismiss.
///
/// Because [InteractiveViewer] is not a [Scrollable] and does not emit
/// scroll notifications, this widget dispatches standard Flutter [ScrollNotification]s
/// when the user pulls down at base scale or at the top boundary of zoomed content.
///
/// To prevent [DismissiblePage]'s raw pan recognizer from competing with
/// [InteractiveViewer], configure [DismissiblePage.gesture] with
/// [DismissibleInteractiveViewer.dragRegion].
class DismissibleInteractiveViewer extends StatefulWidget {
  const DismissibleInteractiveViewer({
    super.key,
    required this.child,
    this.transformationController,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.doubleTapScale = 2.5,
    this.doubleTapEnabled = true,
    this.clipBehavior = Clip.none,
  });

  /// The content to make zoomable and dismissible (e.g. an [Image] or [Hero]).
  final Widget child;

  /// Optional controller to monitor or programmatically drive transformations.
  final TransformationController? transformationController;

  /// The minimum allowed scale.
  final double minScale;

  /// The maximum allowed scale.
  final double maxScale;

  /// Scale factor applied on double tap.
  final double doubleTapScale;

  /// Whether double tap animates zoom in and out.
  final bool doubleTapEnabled;

  /// Clip behavior for the [InteractiveViewer].
  final Clip clipBehavior;

  /// Recommended [DismissiblePageDragRegion] to pass to [DismissiblePageGesture.dragRegion].
  ///
  /// Prevents [DismissiblePage]'s raw pan recognizer from conflicting with
  /// [InteractiveViewer]'s multi-touch and pan gestures.
  static const DismissiblePageDragRegion dragRegion =
      DismissiblePageDragRegion.custom(_rejectAllPointers);

  @override
  State<DismissibleInteractiveViewer> createState() =>
      _DismissibleInteractiveViewerState();
}

class _DismissibleInteractiveViewerState
    extends State<DismissibleInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _controller;
  late final AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;
  bool _isOverScrolling = false;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.transformationController != null) {
      _controller = widget.transformationController!;
    } else {
      _controller = TransformationController();
      _internalController = true;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        final anim = _animation;
        if (anim != null) {
          _controller.value = anim.value;
        }
      });
  }

  @override
  void didUpdateWidget(DismissibleInteractiveViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transformationController != oldWidget.transformationController) {
      if (_internalController) {
        _controller.dispose();
        _internalController = false;
      }
      if (widget.transformationController != null) {
        _controller = widget.transformationController!;
      } else {
        _controller = TransformationController();
        _internalController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.doubleTapEnabled) return;

    final current = _controller.value;
    final Matrix4 target;

    if (!current.isIdentity()) {
      target = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      final scale = widget.doubleTapScale;
      target = Matrix4.diagonal3Values(scale, scale, 1)
        ..setTranslationRaw(
          -position.dx * (scale - 1),
          -position.dy * (scale - 1),
          0,
        );
    }

    _animation = Matrix4Tween(begin: current, end: target).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  FixedScrollMetrics _metrics(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 0,
      pixels: 0,
      viewportDimension: size.height,
      axisDirection: AxisDirection.down,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _isOverScrolling = false;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details, BuildContext context) {
    final scale = _controller.value.getMaxScaleOnAxis();
    // In scene coordinates, 0 is the top edge of the child content.
    // If toScene(Offset.zero).dy <= 0.5, the content is at or beyond the top edge.
    final sceneTop = _controller.toScene(Offset.zero).dy;
    final isAtTopEdge = scale <= 1.05 || sceneTop <= 0.5;
    final dy = details.focalPointDelta.dy;

    if (!_isOverScrolling) {
      // Start overscroll when pulling down at the top edge (or 1.0x scale) with 1 finger
      if (isAtTopEdge && dy > 0 && details.pointerCount == 1) {
        _isOverScrolling = true;
        ScrollStartNotification(
          metrics: _metrics(context),
          context: context,
        ).dispatch(context);

        OverscrollNotification(
          metrics: _metrics(context),
          context: context,
          overscroll: -dy,
        ).dispatch(context);
      }
    } else {
      final currentOffset = DismissiblePage.of(context).offset.dy;

      if (dy > 0) {
        // Dragging further down
        OverscrollNotification(
          metrics: _metrics(context),
          context: context,
          overscroll: -dy,
        ).dispatch(context);
      } else if (dy < 0) {
        if (currentOffset > 0) {
          // Returning back towards origin
          ScrollUpdateNotification(
            metrics: _metrics(context),
            context: context,
            scrollDelta: -dy,
            dragDetails: DragUpdateDetails(
              globalPosition: details.focalPoint,
              delta: Offset(0, dy),
            ),
          ).dispatch(context);
        } else {
          // Reached origin, stop overscroll
          _isOverScrolling = false;
          ScrollEndNotification(
            metrics: _metrics(context),
            context: context,
            dragDetails: DragEndDetails(velocity: Velocity.zero),
          ).dispatch(context);
        }
      }
    }
  }

  void _onInteractionEnd(ScaleEndDetails details, BuildContext context) {
    if (_isOverScrolling) {
      _isOverScrolling = false;
      ScrollEndNotification(
        metrics: _metrics(context),
        context: context,
        dragDetails: DragEndDetails(velocity: details.velocity),
      ).dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox.expand(
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        clipBehavior: widget.clipBehavior,
        onInteractionStart: _onInteractionStart,
        onInteractionUpdate: (details) =>
            _onInteractionUpdate(details, context),
        onInteractionEnd: (details) => _onInteractionEnd(details, context),
        child: Center(child: widget.child),
      ),
    );

    if (widget.doubleTapEnabled) {
      content = GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: content,
      );
    }

    return content;
  }
}

bool _rejectAllPointers(Offset position, Size size) => false;
