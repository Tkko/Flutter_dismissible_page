part of '../dismissible_page.dart';

/// Destination sides used by [DismissiblePage.dismissThresholds].
enum DismissiblePageSide {
  /// The top edge.
  up,

  /// The bottom edge.
  down,

  /// The leading edge: left in LTR, right in RTL.
  start,

  /// The trailing edge: right in LTR, left in RTL.
  end,
}
