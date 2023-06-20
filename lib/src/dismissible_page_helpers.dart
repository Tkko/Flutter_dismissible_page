part of 'dismissible_page.dart';

class _DismissiblePageScrollBehavior extends ScrollBehavior {
  const _DismissiblePageScrollBehavior();

  @override
  Widget buildOverscrollIndicator(_, Widget child, __) => child;
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
    required this.direction,
    required this.child,
    this.onPointerDown,
    Key? key,
  }) : super(key: key);

  final _DismissiblePageMixin parentState;
  final ValueChanged<Offset> onStart;
  final ValueChanged<DragEndDetails> onEnd;
  final ValueChanged<DragUpdateDetails> onUpdate;
  final ValueChanged<PointerDownEvent>? onPointerDown;
  final DismissiblePageDismissDirection direction;
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

  bool _isSameDirections(ScrollMetrics metrics) {
    final Axis axis = metrics.axis;
    switch (direction) {
      case DismissiblePageDismissDirection.vertical:
        return axis == Axis.vertical;
      case DismissiblePageDismissDirection.up:
        return axis == Axis.vertical && metrics.extentAfter == 0;
      case DismissiblePageDismissDirection.down:
        return axis == Axis.vertical && metrics.extentBefore == 0;
      case DismissiblePageDismissDirection.horizontal:
        return axis == Axis.horizontal;
      case DismissiblePageDismissDirection.endToStart:
        return axis == Axis.horizontal && metrics.extentAfter == 0;
      case DismissiblePageDismissDirection.startToEnd:
        return axis == Axis.horizontal && metrics.extentBefore == 0;
      case DismissiblePageDismissDirection.none:
        return false;
      case DismissiblePageDismissDirection.multi:
        return true;
    }
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (_isSameDirections(scrollInfo.metrics)) {
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
