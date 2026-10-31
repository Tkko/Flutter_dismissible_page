part of '../dismissible_page.dart';

/// Configures the background scrim rendered behind a [DismissiblePage].
@immutable
class DismissiblePageBackground {
  /// Transitions smoothly from [from] to [to] as the user drags.
  const DismissiblePageBackground.transition({
    required Color from,
    required Color to,
    this.curve = Curves.linear,
  })  : startColor = from,
        endColor = to;

  /// Fades out [color] from [startOpacity] to [endOpacity].
  ///
  /// Automatically preserves RGB channels during the fade to avoid
  /// muddy color shifts when fading to transparent.
  DismissiblePageBackground.fadeOut(
    Color color, {
    double startOpacity = 1.0,
    double endOpacity = 0.0,
    this.curve = Curves.linear,
  })  : startColor = color.withValues(alpha: startOpacity),
        endColor = color.withValues(alpha: endOpacity);

  /// Keeps a constant [color] throughout the drag gesture.
  const DismissiblePageBackground.solid(Color color)
      : startColor = color,
        endColor = null,
        curve = Curves.linear;

  /// No background color (fully transparent, skips background painting).
  const DismissiblePageBackground.none()
      : startColor = null,
        endColor = null,
        curve = Curves.linear;

  /// The color at the start of the drag gesture (progress = 0.0).
  final Color? startColor;

  /// The color at maximum drag (progress = 1.0).
  final Color? endColor;

  /// The easing curve applied to color interpolation.
  final Curve curve;

  /// Resolves the background color at a given drag [progress] (0.0 to 1.0).
  ///
  /// Returns `null` if no background should be rendered (e.g. [DismissiblePageBackground.none]).
  Color? resolveColor(double progress) {
    if (startColor == null) return null;
    if (endColor == null) return startColor;

    final transformed = curve.transform(progress.clamp(0.0, 1.0));
    return Color.lerp(startColor, endColor, transformed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageBackground &&
          runtimeType == other.runtimeType &&
          startColor == other.startColor &&
          endColor == other.endColor &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(startColor, endColor, curve);
}
