<div align="center">
  <h1 align="center" style="font-size: 70px;">Flutter Dismissible Page From <a href="https://www.linkedin.com/in/thornike/" target="_blank">Tornike</a> </h1>

<!--  Donations -->
 <a href="https://ko-fi.com/flutterman">
  <img width="300" src="https://user-images.githubusercontent.com/26390946/161375567-9e14cd0e-1675-4896-a576-a449b0bcd293.png">
 </a>
 <div align="center">
   <a href="https://www.buymeacoffee.com/fman">
    <img width="150" alt="buymeacoffee" src="https://user-images.githubusercontent.com/26390946/161375563-69c634fd-89d2-45ac-addd-931b03996b34.png">
  </a>
   <a href="https://ko-fi.com/flutterman">
    <img width="150" alt="Ko-fi" src="https://user-images.githubusercontent.com/26390946/161375565-e7d64410-bbcf-4a28-896b-7514e106478e.png">
  </a>
 </div>
<!--  Donations -->

[![Pub package](https://img.shields.io/pub/v/dismissible_page.svg)](https://pub.dev/packages/dismissible_page)
[![Github starts](https://img.shields.io/github/stars/tkko/flutter_dismissible_page.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/tkko/flutter_dismissible_page)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub package](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

</div>

Flutter widget that allows you to dismiss page to any direction, forget the boring back button and
plain transitions.

## Features:

- Dismiss to any direction
- Works with nested list view
- Animating border
- Animating background
- Animating scale

## Support

#### PRs Welcome
#### Discord [Channel](https://rebrand.ly/qwc3s0d)
#### Don't forget to give it a star ⭐

## Demo
| [Live Demo](https://tkko.github.io/Flutter_dismissible_page) | Multi Direction | Vertical |
|--|--|--|
| <a href="https://tkko.github.io/Flutter_dismissible_page"><img width="300" src="https://user-images.githubusercontent.com/26390946/156333539-29aefaf2-5f42-4414-8d8c-1ecbae40c377.png"/></a> | <img src="https://user-images.githubusercontent.com/26390946/161377483-78e5dbaf-678f-4381-a393-52af8180bbcb.gif" /> | <img src="https://user-images.githubusercontent.com/26390946/156391449-a9235d05-bc87-4f51-8a5d-50c44fd0c582.gif"/> |

## Getting Started

```dart

const imageUrl =
    'https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(228, 217, 236, 1),
      body: GestureDetector(
        onTap: () {
          // Use extension method to use [TransparentRoute]
          // This will push page without route background
          context.pushTransparentRoute(SecondPage());
        },
        child: Center(
          child: SizedBox(
            width: 200,
            // Hero widget is needed to animate page transition
            child: Hero(
              tag: 'Unique tag',
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      direction: DismissiblePageDismissDirection.all,
      isFullScreen: false,
      child: Hero(
        tag: 'Unique tag',
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
```

## Scrollable Coordination (ListView, CustomScrollView, PageView)

`DismissiblePage` coordinates seamlessly with inner scrollables:
- **Implicit coordination**: Eligible primary scrollables inherit the controller via `PrimaryScrollController`. Flutter's automatic inheritance depends on platform and scroll axis; explicit controllers and `PageView` do not automatically use it.
- **Builder pattern**: Use `DismissiblePage.builder` to explicitly attach the provided controller to your scrollable.
- **Authentic Scroll Physics**: Works natively with both iOS `BouncingScrollPhysics` and Android `ClampingScrollPhysics`. Inner scroll momentum, bounce, and deceleration remain 100% authentic.

```dart
DismissiblePage.builder(
  onDismissed: () => Navigator.of(context).pop(),
  builder: (context, controller) => ListView.builder(
    controller: controller,
    itemCount: 50,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
)
```

For reliable edge dismissal with `BouncingScrollPhysics`, use the coordinated
controller (inherited or supplied by `DismissiblePage.builder`). With an ordinary
external `ScrollController`, the notification-only fallback retains its existing
limitation: a bounce can return the page to its origin before the scroll ends,
preventing distance-based dismissal.

## Properties

``` dart
  const DismissiblePage({
    required this.onDismissed,
    required Widget child,
    this.controller,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate,
    this.onDragEvent,
    this.onWillDismiss,
    this.onDismissStart,
    this.isFullScreen = true,
    this.enabled = true,
    this.background = const DismissiblePageBackground.transition(
      from: Colors.black,
      to: Colors.transparent,
    ),
    this.borderRadius = const DismissiblePageRadius.transition(),
    this.direction = DismissiblePageDismissDirection.all,
    this.gesture = const DismissiblePageGesture(),
    this.transform = const DismissiblePageTransform(),
    this.dragStartBehavior = DragStartBehavior.down,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.motion = const DismissiblePageMotion(),
    this.semanticLabel,
    super.key,
  })  : _child = child,
        _builder = null;

  /// An optional [DismissiblePageScrollController] for coordinating scrollables.
  final DismissiblePageScrollController? controller;

  /// The content widget, or null when using DismissiblePage.builder.
  Widget? get child => _child;

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Called when the user starts dragging the widget.
  final VoidCallback? onDragStart;

  /// Called when the user ends dragging the widget.
  final VoidCallback? onDragEnd;

  /// Called when a drag gesture is cancelled.
  final VoidCallback? onDragCancel;

  /// Called when the widget has been dragged with progress, offset, radius, scale and opacity details.
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  /// One callback for the whole drag lifecycle (start, update, end, cancel).
  final ValueChanged<DismissiblePageEvent>? onDragEvent;

  /// Asks whether the page may be dismissed (sync or async). False keeps it.
  final FutureOr<bool> Function()? onWillDismiss;

  /// Called when the page starts leaving, right before [onDismissed].
  final VoidCallback? onDismissStart;

  /// If true widget will ignore device padding
  /// [MediaQuery.of(context).padding]
  final bool isFullScreen;

  /// If false, dismiss gesture interactions are disabled.
  final bool enabled;

  /// Configuration for the background scrim behind the dismissing widget.
  final DismissiblePageBackground background;

  /// Configuration for the corner radius applied to the content during drag.
  final DismissiblePageRadius borderRadius;

  /// Sensitivity, minimum scale and extent of the visual effects.
  final DismissiblePageTransform transform;

  /// Thresholds, fling speeds, axis lock and the region a drag may start in.
  final DismissiblePageGesture gesture;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// Rebound, exit, dismiss continuation and haptics of released drags.
  final DismissiblePageMotion motion;

  /// A label announced by assistive technologies for the page.
  final String? semanticLabel;

  /// How to behave during hit tests.
  ///
  /// This defaults to [HitTestBehavior.opaque].
  final HitTestBehavior hitTestBehavior;
```

## Directional dismissal thresholds

`direction` determines which gestures are allowed. `gesture.dismissThresholds` determines
the required page displacement toward each destination side:

```dart
DismissiblePage(
  direction: DismissiblePageDismissDirection.all,
  gesture: const DismissiblePageGesture(
    dismissThresholds: {
      DismissiblePageSide.up: 0.10,
      DismissiblePageSide.down: 0.20,
      DismissiblePageSide.start: 0.30,
      DismissiblePageSide.end: 0.40,
    },
  ),
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

Up/down values are fractions of page height; start/end values are fractions of
page width. For a 600 px tall page, `down: 0.20` requires 120 px of downward page
displacement. `transform.dragSensitivity` still determines how finger movement translates
into page displacement.

`start` means left in LTR and right in RTL; `end` means right in LTR and left in
RTL. Consequently, `startToEnd` uses the `end` threshold and `endToStart` uses
the `start` threshold. With `all`, a diagonal drag dismisses when either axis
reaches its corresponding threshold. Threshold entries never enable directions
excluded by `direction`. Missing sides use 0.18; values must be between 0 and 1.
Fast outward flings can dismiss before a distance threshold is reached, see
[Motion](#motion).

Thresholds are independent of `transform.maxTransformValue`, which controls only visual
effect progress. `onDragUpdate` exposes this visual progress as `details.progress`
(0 to 1), along with offset, scale, radius, and opacity.

## Gesture

`gesture` decides what counts as a dismissing drag:

```dart
DismissiblePage(
  direction: DismissiblePageDismissDirection.all,
  gesture: const DismissiblePageGesture(
    // Page pixels per second, and the fraction of the page that must already
    // have moved, for an outward fling to dismiss before the threshold.
    flingVelocity: 1000,
    flingMinDistance: 0.1,
    // How little speed back towards the origin cancels a release that is past
    // the threshold. Much lower than flingVelocity: changing your mind needs a
    // hint, dismissing needs intent.
    cancelVelocity: 300,
    // With `all`, stick to the axis the drag started along.
    lockAxis: true,
    // Only start a drag within the top 80 px, like a sheet's grab handle.
    dragRegion: DismissiblePageDragRegion.edge(DismissiblePageSide.up, 80),
  ),
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

`dragRegion` limits both the page's own drag and the pull of a scrollable resting
at its edge; the scrollable keeps scrolling normally outside of it. Use
`DismissiblePageDragRegion.custom((position, size) => ...)` for any other shape.

## Transform

`transform` shapes how a drag translates into movement and visual effects:
`dragSensitivity` (finger to page movement), `minScale` (scale at maximum drag)
and `maxTransformValue` (the fraction of the page at which effects finish).

## Motion

`motion` tunes how a released drag animates:

```dart
DismissiblePage(
  motion: const DismissiblePageMotion(
    // Spring seeded with the release velocity (the default).
    rebound: DismissiblePageRebound.spring(stiffness: 900, dampingRatio: 1),
    // Keep moving off-screen from the finger while onDismissed runs...
    continueOnDismiss: true,
    // ...carrying the release velocity (default), or along a curve of your
    // own: DismissiblePageExit.curve(Curves.easeInOutCubic, duration: ...).
    exit: DismissiblePageExit.momentum(),
    // A light haptic each time the dismiss threshold is crossed.
    thresholdHaptics: true,
  ),
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

`DismissiblePageRebound.bouncy()` overshoots the origin slightly, and
`DismissiblePageRebound.curve(curve:, duration:)` is the time-based easing.
`DismissiblePageRebound` and `DismissiblePageExit` are sealed, so a `switch`
over them is exhaustive. `exit` applies to a swipe that slides away
(`continueOnDismiss`) and to `DismissiblePage.dismiss`: `.momentum()` keeps the
release speed, `.curve(curve, duration)` always leaves the same way. `continueOnDismiss` leaves the page off-screen, so
`onDismissed` is expected to remove it.

### Haptics

`thresholdHaptics: true` plays a light impact (`HapticFeedback.lightImpact`) each
time a drag crosses the dismiss threshold, in either direction.

**Android** needs the vibrate permission, otherwise the haptic may not play on
some devices. Add it to `android/app/src/main/AndroidManifest.xml`, outside the
`<application>` element:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.VIBRATE"/>
    <application ...>
```

**iOS** needs no configuration. On web and desktop the call is a no-op, and
devices without a haptic engine, or with system haptics turned off, stay silent.

### Confirming a dismissal

`onWillDismiss` is asked before a release or `DismissiblePage.dismiss` dismisses
the page. Return `false` (or a future completing with `false`) to keep it. While
a future is pending the page is held where it is and ignores further drags.

```dart
DismissiblePage(
  onWillDismiss: () async => await confirmDiscardChanges(context) ?? false,
  onDismissStart: () => debugPrint('leaving'),
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

`onDismissStart` fires right before `onDismissed`, after the confirmation.

### Following the page

`DismissiblePage.of(context)` (or `maybeOf`) returns a handle with `isDragging`,
`isDismissing`, `progress`, `offset` and `dismiss()`. It is a `Listenable`, so a
`ListenableBuilder` can follow the drag without wiring `onDragUpdate`:

```dart
ListenableBuilder(
  listenable: DismissiblePage.of(context),
  builder: (context, _) =>
      LinearProgressIndicator(value: DismissiblePage.of(context).progress),
)
```

`onDragEvent` reports the same lifecycle as `onDragStart`, `onDragUpdate`,
`onDragEnd` and `onDragCancel` through one callback over the sealed
`DismissiblePageEvent`.

### Custom backgrounds and radii

`DismissiblePageBackground.custom((progress) => color)` and
`DismissiblePageRadius.custom((progress) => radius)` compute the value from the
drag progress (0 to 1) for transitions the presets cannot express.

### Accessibility

Screen readers can dismiss the page with their dismiss gesture unless
`direction` is `none`. Set `semanticLabel` to announce the page.

### Dismissing from code

`DismissiblePage.dismiss(context)` closes the page with the same motion as a
swipe: it winds up slightly, then accelerates off-screen towards `side` (by
default the side `direction` dismisses towards) while `onDismissed` runs.

```dart
Builder(
  builder: (context) => IconButton(
    onPressed: () => DismissiblePage.dismiss(context),
    icon: const Icon(Icons.close),
  ),
)
```

The context must be inside the page. Use a `Builder` when the button is built by
the widget that creates the `DismissiblePage`.

### Avoiding accidental dismissals

Dismissing needs clear intent, and the defaults lean towards keeping the page:

- A release past the threshold that is drifting back towards the origin
  (faster than `cancelVelocity`) cancels, even though the page was far enough.
- A fling only dismisses before the threshold when it is fast
  (`flingVelocity`) and the page has already moved `flingMinDistance`.
- A pull on a scrollable only dismisses the page when the gesture began at that
  edge. Scrolling quickly to the top and carrying on stays a scroll; lift and
  pull again to dismiss.
- `onDragUpdate` reports `details.willDismiss`, true while letting go would
  dismiss by distance, so you can show a "release to close" hint.

If the page contains something draggable that competes with the dismiss
gesture, such as a zoomable image or a slider, set `enabled: false` while it is
being used.

## Transparent routes

Direct route construction now has the same defaults as `pushTransparentRoute`:
a transparent background and 250 ms forward/reverse transitions.

```dart
Navigator.of(context).push(
  TransparentRoute<void>(
    builder: (_) => SecondPage(),
  ),
);
```

`TransparentRoute` and `pushTransparentRoute` also take `barrierDismissible`
(default true), `opaque` (default false) and a `transitionBuilder` (a fade by
default).

`onDismissed` remains explicit; `DismissiblePage` does not pop a route itself.

## Migration

These are breaking API changes:

- Use `DismissiblePage(child: ...)` or `DismissiblePage.builder(builder: ...)`;
  content is required and cannot be specified both ways.
- Rename `DismissiblePageDismissDirection.multi` to `.all`.
- Rename `overallDragValue` to `progress`, including constructor arguments and
  the key returned by `DismissiblePageDragUpdateDetails.toMap()`.
- Replace direction keys in `dismissThresholds` with `DismissiblePageSide`
  keys. Expand a vertical threshold into up/down entries, horizontal into
  start/end, and multi into all four sides. Map `startToEnd` to `end` and
  `endToStart` to `start`.
- Threshold values now measure page displacement rather than visual progress.
  To preserve an old distance threshold, multiply its effective value by the
  old `maxTransformValue`. The old default distance was `0.15 * 0.4 = 0.06`;
  the new default is `0.18` of the page dimension. Diagonal thresholds are
  evaluated independently for each axis.

- `dragSensitivity`, `minScale` and `maxTransformValue` moved into
  `transform: DismissiblePageTransform(...)`.
- `dismissThresholds`, `flingVelocity`, `flingMinDistance` and `cancelVelocity`
  moved into `gesture: DismissiblePageGesture(...)`.
- `reverseDuration` is now `DismissiblePageRebound.curve(duration: ...)`.
- `DismissiblePageRebound` and `DismissiblePageExit` are sealed classes. Test
  variants with `is DismissiblePageSpringRebound` and so on instead of
  `isSpring`.
- `DismissiblePageDragUpdateDetails` compares all of its fields, not only
  `offset`.
- `GlobalKeyExtension.globalPaintBounds` was removed.

`background` and `borderRadius` remain widget arguments.
