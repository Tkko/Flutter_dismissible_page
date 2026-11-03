part of '../dismissible_page.dart';

/// Details outputted by [DismissiblePage.onDragUpdate] method
@immutable
class DismissiblePageDragUpdateDetails {
  ///
  const DismissiblePageDragUpdateDetails({
    required this.radius,
    required this.opacity,
    this.offset = Offset.zero,
    this.progress = 0.0,
    this.scale = 1.0,
    this.willDismiss = false,
  });

  /// Visual effect progress from 0.0 to 1.0, not dismissal distance progress.
  final double progress;
  final double radius;
  final double opacity;
  final double scale;
  final Offset offset;

  /// Whether letting go now would dismiss by distance: the page has been
  /// dragged past its dismiss threshold.
  ///
  /// Use it to show that the gesture is committed, for example a "release to
  /// close" hint. A fast outward fling can still dismiss before this is true,
  /// and a drift back towards the origin at release can still cancel it.
  final bool willDismiss;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageDragUpdateDetails &&
          runtimeType == other.runtimeType &&
          offset == other.offset;

  @override
  int get hashCode => offset.hashCode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'progress': progress,
        'radius': radius,
        'opacity': opacity,
        'scale': scale,
        'offset': offset,
        'willDismiss': willDismiss,
      };

  @override
  String toString() => toMap().toString();
}
