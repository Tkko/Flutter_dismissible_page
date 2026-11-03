part of '../dismissible_page.dart';

/// How a drag translates into the movement and visual effects of a
/// [DismissiblePage].
@immutable
class DismissiblePageTransform {
  ///
  const DismissiblePageTransform({
    this.dragSensitivity = 0.7,
    this.minScale = 0.85,
    this.maxTransformValue = 0.4,
  })  : assert(dragSensitivity > 0, 'dragSensitivity must be greater than 0'),
        assert(
          minScale >= 0 && minScale <= 1,
          'minScale must be between 0.0 and 1.0',
        ),
        assert(
          maxTransformValue >= 0 && maxTransformValue <= 1,
          'maxTransformValue must be between 0.0 and 1.0',
        );

  /// Multiplier applied to drag movements.
  final double dragSensitivity;

  /// The scale of the widget at maximum drag.
  final double minScale;

  /// Fraction of page dimension at which visual effects reach their final
  /// values.
  ///
  /// Does not limit translation or affect
  /// [DismissiblePageGesture.dismissThresholds]. When zero, effects reach
  /// their final values at any nonzero offset.
  final double maxTransformValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageTransform &&
          dragSensitivity == other.dragSensitivity &&
          minScale == other.minScale &&
          maxTransformValue == other.maxTransformValue;

  @override
  int get hashCode => Object.hash(dragSensitivity, minScale, maxTransformValue);
}
