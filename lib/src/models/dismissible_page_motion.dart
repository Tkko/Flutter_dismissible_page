part of '../dismissible_page.dart';

/// How the page returns to its origin when a drag ends without dismissing.
@immutable
class DismissiblePageRebound {
  /// A time-based rebound that ignores release velocity and runs for
  /// [DismissiblePage.reverseDuration].
  const DismissiblePageRebound.curve({this.curve = Curves.easeOutCubic})
      : isSpring = false,
        stiffness = 0,
        dampingRatio = 0;

  /// A physics-based rebound that starts from the release velocity.
  ///
  /// A [dampingRatio] of 1 settles without overshoot, lower values overshoot
  /// the origin and oscillate before settling.
  const DismissiblePageRebound.spring({
    this.stiffness = 900,
    this.dampingRatio = 1.0,
  })  : assert(stiffness > 0, 'stiffness must be greater than 0'),
        assert(dampingRatio > 0, 'dampingRatio must be greater than 0'),
        isSpring = true,
        curve = Curves.linear;

  /// A spring that overshoots the origin slightly before settling.
  const DismissiblePageRebound.bouncy() : this.spring(dampingRatio: 0.65);

  /// Whether the rebound is driven by a spring simulation.
  final bool isSpring;

  /// The easing curve of a [DismissiblePageRebound.curve] rebound.
  final Curve curve;

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
      other is DismissiblePageRebound &&
          isSpring == other.isSpring &&
          curve == other.curve &&
          stiffness == other.stiffness &&
          dampingRatio == other.dampingRatio;

  @override
  int get hashCode => Object.hash(isSpring, curve, stiffness, dampingRatio);
}

/// How the page leaves the screen when it is dismissed.
///
/// It applies when the page slides away itself, that is when
/// [DismissiblePageMotion.continueOnDismiss] is on, and to
/// [DismissiblePage.dismiss].
@immutable
class DismissiblePageExit {
  /// Carries the release velocity: a fast release keeps its speed and eases
  /// out, a slow one accelerates away from rest. [DismissiblePage.dismiss],
  /// which has no velocity, winds up slightly and then accelerates away.
  const DismissiblePageExit.momentum()
      : curve = null,
        duration = null;

  /// Always leaves along [curve] over [duration], whatever the release speed.
  ///
  /// A curve that dips below zero at first, such as [Curves.easeInBack],
  /// winds up against the exit direction before leaving.
  const DismissiblePageExit.curve(
    Curve this.curve, {
    this.duration = const Duration(milliseconds: 300),
  });

  /// The exit curve, or null for [DismissiblePageExit.momentum].
  final Curve? curve;

  /// How long the exit takes, or null for [DismissiblePageExit.momentum].
  final Duration? duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageExit &&
          curve == other.curve &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(curve, duration);
}

/// Tunes how [DismissiblePage] animates a released drag.
@immutable
class DismissiblePageMotion {
  ///
  const DismissiblePageMotion({
    this.rebound = const DismissiblePageRebound.spring(),
    this.exit = const DismissiblePageExit.momentum(),
    this.continueOnDismiss = false,
    this.thresholdHaptics = false,
    this.flingVelocity = 1000,
    this.flingMinDistance = 0.1,
    this.cancelVelocity = 300,
  })  : assert(flingVelocity > 0, 'flingVelocity must be greater than 0'),
        assert(cancelVelocity >= 0, 'cancelVelocity must not be negative'),
        assert(
          flingMinDistance >= 0 && flingMinDistance <= 1,
          'flingMinDistance must be between 0.0 and 1.0',
        );

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

  /// Release speed, in page pixels per second, above which an outward drag is
  /// a fling that dismisses the page before it reaches its dismiss threshold.
  ///
  /// Page pixels are [DismissiblePage.dragSensitivity] times finger pixels.
  /// Use [double.infinity] to dismiss by distance only.
  final double flingVelocity;

  /// Fraction of the page dimension the page must have moved before an
  /// outward fling can dismiss it, so a flick from a near-resting page does
  /// not.
  final double flingMinDistance;

  /// Release speed, in page pixels per second, above which a drag back towards
  /// the origin cancels the dismissal, even when the page is past its
  /// threshold.
  ///
  /// It is much lower than [flingVelocity] on purpose: changing your mind
  /// needs only a hint, while dismissing needs clear intent, so a page that is
  /// drifting back is never dismissed by accident. Use 0 to cancel on any
  /// inward movement, or [double.infinity] to never cancel.
  final double cancelVelocity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DismissiblePageMotion &&
          rebound == other.rebound &&
          exit == other.exit &&
          continueOnDismiss == other.continueOnDismiss &&
          thresholdHaptics == other.thresholdHaptics &&
          flingVelocity == other.flingVelocity &&
          flingMinDistance == other.flingMinDistance &&
          cancelVelocity == other.cancelVelocity;

  @override
  int get hashCode => Object.hash(
        rebound,
        exit,
        continueOnDismiss,
        thresholdHaptics,
        flingVelocity,
        flingMinDistance,
        cancelVelocity,
      );
}
