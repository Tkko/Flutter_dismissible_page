part of 'dismissible_page.dart';

// Every tuning constant of the library lives here, so the feel of a dismissal
// can be read and adjusted in one place.
//
// The defaults of public parameters (for example the fields of
// `DismissiblePageMotion` or `DismissiblePageGesture`) stay inline in their
// signatures instead,
// so that the generated documentation shows their values.

/// The fraction of the page a drag must cover to dismiss it, for sides that
/// have no entry in `dismissThresholds`.
const double _kDismissThreshold = 0.18;

/// How far from its edge, in logical pixels, a scrollable still counts as
/// resting at that edge, so a bounce that has not quite settled does not stop
/// a pull from dismissing the page.
const double _kEdgeTolerance = 2;

/// Winds up by about 1.5% of the travel, then accelerates away. Unlike
/// [Curves.easeInBack], whose wind-up is roughly 10%, it reads as a nudge
/// instead of a bounce.
const Curve _kExitCurve = Cubic(0.55, -0.12, 0.85, 0.45);

/// How long [DismissiblePage.dismiss] takes to leave, unless the motion's exit
/// sets its own duration.
const Duration _kDismissDuration = Duration(milliseconds: 340);

/// Release speed, in page pixels per second, from which a page leaving the
/// screen keeps its momentum instead of accelerating away from rest.
const double _kMomentumVelocity = 400;

const Duration _kSlowExitDuration = Duration(milliseconds: 280);

/// The shortest and longest a page leaving with momentum takes, in
/// milliseconds. A faster release leaves sooner, within these bounds.
const double _kMomentumExitMinMs = 140;
const double _kMomentumExitMaxMs = 260;

/// How fast `Curves.easeOutCubic` starts, as a multiple of its average speed.
/// Used to make a page leave at the speed it was released at.
const double _kEaseOutCubicStartSlope = 3;

/// A spring is done once its remaining motion is below this many pixels...
const double _kSpringDistanceTolerance = 0.25;

/// ...and this many pixels per second, so it settles without a visible tail.
const double _kSpringVelocityTolerance = 5;

const Duration _transitionDuration = Duration(milliseconds: 250);
