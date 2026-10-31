part of '../dismissible_page.dart';

/// Configures the corner radius applied to the content of a [DismissiblePage] during dragging.
@immutable
class DismissiblePageRadius {
  /// Transitions corner radius smoothly from [from] to [to] as the user drags.
  const DismissiblePageRadius.transition({
    this.from = 7.0,
    this.to = 30.0,
    this.curve = Curves.linear,
  });

  /// Keeps a constant corner [radius] throughout the gesture.
  const DismissiblePageRadius.fixed(double radius)
      : from = radius,
        to = radius,
        curve = Curves.linear;

  /// No corner clipping applied.
  const DismissiblePageRadius.none()
      : from = 0.0,
        to = 0.0,
        curve = Curves.linear;

  /// Corner radius at the start of the drag gesture (progress = 0.0).
  final double from;

  /// Corner radius at maximum drag (progress = 1.0).
  final double to;

  /// The easing curve applied to radius interpolation.
  final Curve curve;

  /// Resolves the corner radius at a given drag [progress] (0.0 to 1.0).
  double resolveRadius(double progress) {
    if (from == to) return from;
    final transformed = curve.transform(progress.clamp(0.0, 1.0));
    return from + (to - from) * transformed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageRadius &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(from, to, curve);
}
