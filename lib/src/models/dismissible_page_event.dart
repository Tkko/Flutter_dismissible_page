part of '../dismissible_page.dart';

/// A drag lifecycle event reported by [DismissiblePage.onDragEvent].
///
/// One callback for the whole lifecycle, so a `switch` can handle every case
/// exhaustively instead of wiring four separate callbacks.
@immutable
sealed class DismissiblePageEvent {
  const DismissiblePageEvent();
}

/// A drag began.
final class DismissiblePageDragStartEvent extends DismissiblePageEvent {
  /// Creates a drag start event.
  const DismissiblePageDragStartEvent();
}

/// The page moved during a drag or while settling.
final class DismissiblePageDragUpdateEvent extends DismissiblePageEvent {
  /// Creates a drag update event.
  const DismissiblePageDragUpdateEvent(this.details);

  /// The state of the page after the move.
  final DismissiblePageDragUpdateDetails details;
}

/// A drag ended, either settling back or dismissing.
final class DismissiblePageDragEndEvent extends DismissiblePageEvent {
  /// Creates a drag end event.
  const DismissiblePageDragEndEvent();
}

/// A drag was cancelled.
final class DismissiblePageDragCancelEvent extends DismissiblePageEvent {
  /// Creates a drag cancel event.
  const DismissiblePageDragCancelEvent();
}
