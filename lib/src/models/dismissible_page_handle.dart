part of '../dismissible_page.dart';

/// The state and controls of a [DismissiblePage], from
/// [DismissiblePage.of].
///
/// It is a [Listenable] that notifies whenever the page moves, so it can drive
/// a [ListenableBuilder] for UI that follows the drag, such as a progress
/// indicator, without [DismissiblePage.onDragUpdate] plumbing.
@immutable
class DismissiblePageHandle implements Listenable {
  const DismissiblePageHandle._(this._arbiter);

  final _DismissibleArbiter _arbiter;

  /// Whether the user is dragging the page.
  bool get isDragging => _arbiter.isDragging;

  /// Whether the page is leaving the screen.
  bool get isDismissing => _arbiter.isDismissing;

  /// Visual effect progress from 0.0 to 1.0, as in
  /// [DismissiblePageDragUpdateDetails.progress].
  double get progress => _arbiter.progress;

  /// How far the page is displaced from its origin.
  Offset get offset => _arbiter.offset;

  /// Dismisses the page from code, like [DismissiblePage.dismiss].
  void dismiss({DismissiblePageSide? side}) => _arbiter.dismiss(side: side);

  @override
  void addListener(VoidCallback listener) => _arbiter.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _arbiter.removeListener(listener);

  @override
  bool operator ==(Object other) =>
      other is DismissiblePageHandle && _arbiter == other._arbiter;

  @override
  int get hashCode => _arbiter.hashCode;
}
