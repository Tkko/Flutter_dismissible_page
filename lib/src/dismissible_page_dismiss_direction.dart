part of 'dismissible_page.dart';

///
enum DismissiblePageDismissDirection {
  /// Can be dismissed by dragging either up or down.
  vertical,

  /// Can be dismissed by dragging either left or right.
  horizontal,

  /// Can be dismissed by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// Can be dismissed by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// Can be dismissed by dragging up only.
  up,

  /// Can be dismissed by dragging down only.
  down,

  /// Can be dismissed by dragging any direction.
  multi,

  /// Cannot be dismissed by dragging.
  none;

  /// The axis of the dismiss direction.
  List<Axis> get axes => switch (this) {
    vertical => [Axis.vertical],
    horizontal => [Axis.horizontal],
    endToStart => [Axis.horizontal],
    startToEnd => [Axis.horizontal],
    up => [Axis.vertical],
    down => [Axis.vertical],
    multi => [Axis.vertical, Axis.horizontal],
    none => [],
  };
}
