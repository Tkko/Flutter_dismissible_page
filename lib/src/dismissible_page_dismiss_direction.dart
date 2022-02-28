part of 'dismissible_page.dart';

enum DismissiblePageDismissDirection {
  /// The [DismissiblePageDirection] can be dismissed by dragging either up or down.
  vertical,

  /// The [DismissiblePageDirection] can be dismissed by dragging either left or right.
  horizontal,

  /// The [DismissiblePageDirection] can be dismissed by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// The [DismissiblePageDirection] can be dismissed by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// The [DismissiblePageDirection] can be dismissed by dragging up only.
  up,

  /// The [DismissiblePageDirection] can be dismissed by dragging down only.
  down,

  /// The [DismissiblePageDirection] can be dismissed by dragging any direction.
  multi,

  /// The [DismissiblePageDirection] cannot be dismissed by dragging.
  none
}
