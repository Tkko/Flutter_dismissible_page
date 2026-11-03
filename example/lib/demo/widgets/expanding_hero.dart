import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A [Hero] for whole widgets that grow into a page, like the cards on the
/// App Store's Today tab: the card's visual expands to the page header while
/// its corners square off, and the same in reverse on dismiss, starting from
/// wherever the drag left the page.
///
/// Give the card and the page header the same [tag]. [radius] is the corner
/// radius of that side at rest, so a card passes its radius and the header
/// passes 0. The [child] must lay out to whatever size it is given.
class ExpandingHero extends StatelessWidget {
  const ExpandingHero({
    required this.tag,
    required this.child,
    this.radius = 0,
    super.key,
  });

  final Object tag;
  final Widget child;
  final double radius;

  /// Marks the shuttle so tests can read its radius during a flight.
  static const shuttleKey = ValueKey('expanding-hero-shuttle');

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: _buildShuttle,
      child: _RoundedChild(radius: radius, child: child),
    );
  }

  static Widget _buildShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final from = (fromHeroContext.widget as Hero).child as _RoundedChild;
    final to = (toHeroContext.widget as Hero).child as _RoundedChild;
    final cardRadius = max(from.radius, to.radius);
    final pageRadius = min(from.radius, to.radius);

    // The flight animation follows the route that is moving: 0 is the card
    // and 1 is the page on a push, and it runs back from 1 to 0 on a pop.
    // The shuttle flies in the overlay, outside any Scaffold, so without a
    // Material text would fall back to the default yellow-underlined style.
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: animation,
        child: to.child,
        builder: (context, child) => ClipRRect(
          key: shuttleKey,
          borderRadius: BorderRadius.circular(
            lerpDouble(cardRadius, pageRadius, animation.value)!,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoundedChild extends StatelessWidget {
  const _RoundedChild({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (radius == 0) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }
}
