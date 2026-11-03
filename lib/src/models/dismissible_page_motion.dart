part of '../dismissible_page.dart';

/// How the page returns to its origin when a drag ends without dismissing.
@immutable
sealed class DismissiblePageRebound {
  const DismissiblePageRebound();

  /// A time-based rebound that ignores release velocity and runs for
  /// [DismissiblePageCurveRebound.duration] along
  /// [DismissiblePageCurveRebound.curve].
  const factory DismissiblePageRebound.curve({
    Curve curve,
    Duration duration,
  }) = DismissiblePageCurveRebound;

  /// A physics-based rebound that starts from the release velocity.
  ///
  /// A damping ratio of 1 settles without overshoot, lower values overshoot
  /// the origin and oscillate before settling.
  const factory DismissiblePageRebound.spring({
    double stiffness,
    double dampingRatio,
  }) = DismissiblePageSpringRebound;

  /// A spring that overshoots the origin slightly before settling.
  const factory DismissiblePageRebound.bouncy() =
      DismissiblePageSpringRebound.bouncy;
}

/// A [DismissiblePageRebound] that eases back along a [curve].
class DismissiblePageCurveRebound extends DismissiblePageRebound {
  /// Creates a time-based rebound.
  const DismissiblePageCurveRebound({
    this.curve = Curves.easeOutCubic,
    this.duration = const Duration(milliseconds: 200),
  });

  /// The easing curve of the rebound.
  final Curve curve;

  /// How long the rebound takes.
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageCurveRebound &&
          curve == other.curve &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(curve, duration);
}

/// A [DismissiblePageRebound] driven by a spring simulation.
class DismissiblePageSpringRebound extends DismissiblePageRebound {
  /// Creates a spring rebound.
  const DismissiblePageSpringRebound({
    this.stiffness = 900,
    this.dampingRatio = 1.0,
  })  : assert(stiffness > 0, 'stiffness must be greater than 0'),
        assert(dampingRatio > 0, 'dampingRatio must be greater than 0');

  /// A spring that overshoots the origin slightly before settling.
  const DismissiblePageSpringRebound.bouncy() : this(dampingRatio: 0.65);

  /// Spring stiffness, for a mass of 1.
  final double stiffness;

  /// Spring damping relative to critical damping.
  final double dampingRatio;

  SpringDescription get _spring => SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: stiffness,
        ratio: dampingRatio,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageSpringRebound &&
          stiffness == other.stiffness &&
          dampingRatio == other.dampingRatio;

  @override
  int get hashCode => Object.hash(stiffness, dampingRatio);
}

/// How the page leaves the screen when it is dismissed.
///
/// It applies when the page slides away itself, that is when
/// [DismissiblePageMotion.continueOnDismiss] is on, and to
/// [DismissiblePage.dismiss].
@immutable
sealed class DismissiblePageExit {
  const DismissiblePageExit();

  /// Carries the release velocity: a fast release keeps its speed and eases
  /// out, a slow one accelerates away from rest. [DismissiblePage.dismiss],
  /// which has no velocity, winds up slightly and then accelerates away.
  const factory DismissiblePageExit.momentum() = DismissiblePageMomentumExit;

  /// Always leaves along [curve] over [duration], whatever the release speed.
  ///
  /// A curve that dips below zero at first, such as [Curves.easeInBack],
  /// winds up against the exit direction before leaving.
  const factory DismissiblePageExit.curve(
    Curve curve, {
    Duration duration,
  }) = DismissiblePageCurveExit;
}

/// A [DismissiblePageExit] that carries the release velocity.
class DismissiblePageMomentumExit extends DismissiblePageExit {
  /// Creates a momentum exit.
  const DismissiblePageMomentumExit();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DismissiblePageMomentumExit;

  @override
  int get hashCode => (DismissiblePageMomentumExit).hashCode;
}

/// A [DismissiblePageExit] along a fixed curve and duration.
class DismissiblePageCurveExit extends DismissiblePageExit {
  /// Creates an exit along [curve] over [duration].
  const DismissiblePageCurveExit(
    this.curve, {
    this.duration = const Duration(milliseconds: 300),
  });

  /// The exit curve.
  final Curve curve;

  /// How long the exit takes.
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageCurveExit &&
          curve == other.curve &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(curve, duration);
}

/// Tunes how [DismissiblePage] animates a released drag.
///
/// What counts as a dismissal (thresholds, fling speeds) is configured by
/// [DismissiblePageGesture].
@immutable
class DismissiblePageMotion {
  ///
  const DismissiblePageMotion({
    this.rebound = const DismissiblePageRebound.spring(),
    this.exit = const DismissiblePageExit.momentum(),
    this.continueOnDismiss = false,
    this.thresholdHaptics = false,
  });

  /// How the page returns to its origin when a drag ends without dismissing.
  final DismissiblePageRebound rebound;

  /// How the page leaves the screen when it is dismissed.
  final DismissiblePageExit exit;

  /// Whether the page keeps moving off-screen in the drag direction, carrying
  /// the release velocity, while [DismissiblePage.onDismissed] runs.
  ///
  /// The page stays off-screen afterwards, so [DismissiblePage.onDismissed]
  /// is expected to remove it.
  final bool continueOnDismiss;

  /// Whether a light impact haptic fires each time a drag crosses the dismiss
  /// threshold in either direction.
  final bool thresholdHaptics;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageMotion &&
          rebound == other.rebound &&
          exit == other.exit &&
          continueOnDismiss == other.continueOnDismiss &&
          thresholdHaptics == other.thresholdHaptics;

  @override
  int get hashCode => Object.hash(
        rebound,
        exit,
        continueOnDismiss,
        thresholdHaptics,
      );
}
