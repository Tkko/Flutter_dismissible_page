part of '../dismissible_page.dart';

/// Configures the corner radius applied to the content of a [DismissiblePage] during dragging.
@immutable
class DismissiblePageRadius {
  /// Transitions corner radius smoothly from [from] to [to] as the user drags.
  const DismissiblePageRadius.transition({
    this.from = 7.0,
    this.to = 30.0,
    this.curve = Curves.linear,
  }) : _resolver = null;

  /// Keeps a constant corner [radius] throughout the gesture.
  const DismissiblePageRadius.fixed(double radius)
      : from = radius,
        to = radius,
        curve = Curves.linear,
        _resolver = null;

  /// No corner clipping applied.
  const DismissiblePageRadius.none()
      : from = 0.0,
        to = 0.0,
        curve = Curves.linear,
        _resolver = null;

  /// Computes the corner radius from the drag progress (0.0 to 1.0) with
  /// `resolver`, for transitions [DismissiblePageRadius.transition] cannot
  /// express.
  const DismissiblePageRadius.custom(
    double Function(double progress) this._resolver,
  )   : from = 0.0,
        to = 0.0,
        curve = Curves.linear;

  final double Function(double progress)? _resolver;

  /// Whether this radius configuration applies no corner clipping.
  bool get isNone => from == 0.0 && to == 0.0 && _resolver == null;

  /// Corner radius at the start of the drag gesture (progress = 0.0).
  ///
  /// Zero for [DismissiblePageRadius.custom].
  final double from;

  /// Corner radius at maximum drag (progress = 1.0).
  ///
  /// Zero for [DismissiblePageRadius.custom].
  final double to;

  /// The easing curve applied to radius interpolation.
  final Curve curve;

  /// Resolves the corner radius at a given drag [progress] (0.0 to 1.0).
  double resolveRadius(double progress) {
    final resolver = _resolver;
    if (resolver != null) {
      return max(0, resolver(progress.clamp(0.0, 1.0)));
    }
    if (from == to) return from;
    return from + (to - from) * _easedProgress(curve, progress);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageRadius &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          curve == other.curve &&
          _resolver == other._resolver;

  @override
  int get hashCode => Object.hash(from, to, curve, _resolver);
}
