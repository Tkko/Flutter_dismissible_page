part of 'dismissible_page.dart';

/// Defines how dismiss gestures are coordinated with nested scrollables.
enum DismissiblePageInteractionMode {
  /// Uses a custom [ScrollController]/[ScrollPosition] pair that arbitrates
  /// scroll deltas between page dismissal and inner scrolling.
  scroll,

  /// Uses gesture and scroll-notification based dismissal handling.
  gesture,
}
