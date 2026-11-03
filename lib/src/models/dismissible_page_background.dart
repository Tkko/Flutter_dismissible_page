part of '../dismissible_page.dart';

/// Eases a drag [progress] along [curve], clamped to 0.0 to 1.0.
///
/// Shared by [DismissiblePageBackground] and [DismissiblePageRadius].
double _easedProgress(Curve curve, double progress) =>
    curve.transform(progress.clamp(0.0, 1.0));

/// Configures the background scrim rendered behind a [DismissiblePage].
@immutable
class DismissiblePageBackground {
  /// Transitions smoothly from [from] to [to] as the user drags.
  const DismissiblePageBackground.transition({
    required Color from,
    required Color to,
    this.curve = Curves.linear,
  })  : startColor = from,
        endColor = to,
        _resolver = null;

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
        endColor = color.withValues(alpha: endOpacity),
        _resolver = null;

  /// Keeps a constant [color] throughout the drag gesture.
  const DismissiblePageBackground.solid(Color color)
      : startColor = color,
        endColor = null,
        curve = Curves.linear,
        _resolver = null;

  /// No background color (fully transparent, skips background painting).
  const DismissiblePageBackground.none()
      : startColor = null,
        endColor = null,
        curve = Curves.linear,
        _resolver = null;

  /// Computes the color from the drag progress (0.0 to 1.0) with `resolver`,
  /// for transitions the other constructors cannot express, such as a
  /// multi-stop gradient of colors. Return null for no background.
  const DismissiblePageBackground.custom(
    Color? Function(double progress) this._resolver,
  )   : startColor = null,
        endColor = null,
        curve = Curves.linear;

  final Color? Function(double progress)? _resolver;

  /// Whether this background configuration defines no background painting.
  bool get isNone =>
      startColor == null && endColor == null && _resolver == null;

  /// The color at the start of the drag gesture (progress = 0.0).
  ///
  /// Null for [DismissiblePageBackground.custom].
  final Color? startColor;

  /// The color at maximum drag (progress = 1.0).
  ///
  /// Null for [DismissiblePageBackground.custom].
  final Color? endColor;

  /// The easing curve applied to color interpolation.
  final Curve curve;

  /// Resolves the background color at a given drag [progress] (0.0 to 1.0).
  ///
  /// Returns `null` if no background should be rendered (e.g. [DismissiblePageBackground.none]).
  Color? resolveColor(double progress) {
    final resolver = _resolver;
    if (resolver != null) return resolver(progress.clamp(0.0, 1.0));
    if (startColor == null) return null;
    if (endColor == null) return startColor;

    return Color.lerp(startColor, endColor, _easedProgress(curve, progress));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageBackground &&
          runtimeType == other.runtimeType &&
          startColor == other.startColor &&
          endColor == other.endColor &&
          curve == other.curve &&
          _resolver == other._resolver;

  @override
  int get hashCode => Object.hash(startColor, endColor, curve, _resolver);
}
