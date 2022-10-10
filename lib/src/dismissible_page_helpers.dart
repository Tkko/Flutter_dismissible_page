part of 'dismissible_page.dart';

class _DismissiblePageScrollBehavior extends ScrollBehavior {
  const _DismissiblePageScrollBehavior();

  @override
  Widget buildOverscrollIndicator(_, Widget child, __) => child;

// @override
// TargetPlatform getPlatform(BuildContext context) => TargetPlatform.android;
//
// @override
// ScrollPhysics getScrollPhysics(_) =>
//     const ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics());
// const BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());
}

mixin _DismissiblePageMixin {
  late final AnimationController _moveController;
  int _activePointerCount = 0;

  // ignore: prefer_final_fields
  bool _dragUnderway = false;

  bool get _isActive => _dragUnderway || _moveController.isAnimating;
}

class _DismissiblePageListener extends StatelessWidget {
  const _DismissiblePageListener({
    required this.parentState,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.child,
    this.onPointerDown,
    Key? key,
  }) : super(key: key);
  final _DismissiblePageMixin parentState;
  final ValueChanged<Offset> onStart;
  final ValueChanged<DragEndDetails> onEnd;
  final ValueChanged<DragUpdateDetails> onUpdate;
  final ValueChanged<PointerDownEvent>? onPointerDown;
  final Widget child;

  bool get _dragUnderway => parentState._dragUnderway;

  void _startOrUpdateDrag(DragUpdateDetails? details) {
    if (details == null) return;
    if (_dragUnderway) {
      onUpdate(details);
    } else {
      onStart(details.globalPosition);
    }
  }

  void _updateDrag(DragUpdateDetails? details) {
    if (details != null && details.primaryDelta != null) {
      if (_dragUnderway) {
        onUpdate(details);
      }
    }
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    // final shouldEndDrag = _dragUnderway &&
    //     (scrollInfo.metrics.atEdge || !scrollInfo.metrics.outOfRange);
    // if (shouldEndDrag) {
    //   onEnd(DragEndDetails());
    //   return false;
    // }

    if (scrollInfo is OverscrollNotification) {
      _startOrUpdateDrag(scrollInfo.dragDetails);
      return false;
    }

    if (scrollInfo is ScrollUpdateNotification) {
      if (scrollInfo.metrics.outOfRange) {
        _startOrUpdateDrag(scrollInfo.dragDetails);
      } else {
        _updateDrag(scrollInfo.dragDetails);
      }
      return false;
    }
    return false;
  }

  void _onPointerDown(PointerDownEvent event) {
    parentState._activePointerCount++;
    onPointerDown?.call(event);
  }

  void _onPointerUp(_) {
    parentState._activePointerCount--;
    if (_dragUnderway && parentState._activePointerCount == 0) {
      onEnd(DragEndDetails());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerCancel: _onPointerUp,
      onPointerUp: _onPointerUp,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: child,
      ),
    );
  }
}
