<div align="center">

# Dismissible Page

**Dismiss any Flutter page in any direction. Forget the back button and plain transitions.**

[![Pub](https://img.shields.io/pub/v/dismissible_page.svg)](https://pub.dev/packages/dismissible_page)
[![CI](https://github.com/Tkko/Flutter_dismissible_page/actions/workflows/ci.yml/badge.svg)](https://github.com/Tkko/Flutter_dismissible_page/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/Tkko/Flutter_dismissible_page.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Tkko/Flutter_dismissible_page)
[![Style](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

[Live demo](https://tkko.github.io/Flutter_dismissible_page) · [Install](#install) · [Usage](#usage) · [Properties](#properties) · [Migration](#migration) · [pub.dev](https://pub.dev/packages/dismissible_page) · [Changelog](CHANGELOG.md)

</div>

<br>

| [Live demo](https://tkko.github.io/Flutter_dismissible_page) | Multi direction | Vertical |
| :---: | :---: | :---: |
| <a href="https://tkko.github.io/Flutter_dismissible_page"><img width="260" src="https://user-images.githubusercontent.com/26390946/156333539-29aefaf2-5f42-4414-8d8c-1ecbae40c377.png" alt="Live demo"/></a> | <img width="260" src="https://user-images.githubusercontent.com/26390946/161377483-78e5dbaf-678f-4381-a393-52af8180bbcb.gif" alt="Multi direction"/> | <img width="260" src="https://user-images.githubusercontent.com/26390946/156391449-a9235d05-bc87-4f51-8a5d-50c44fd0c582.gif" alt="Vertical"/> |

## Features

- Dismiss in any direction
- Works with nested scrollables (`ListView`, `CustomScrollView`, `PageView`)
- Animated border radius, background and scale
- Tunable thresholds, flings, rebound, exit motion and haptics
- Confirm or cancel a dismissal, or dismiss from code
- Accessible: screen readers can dismiss the page

## Platform support

| Android | iOS | Web | macOS | Windows | Linux |
| :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

Threshold haptics are a no-op on web and desktop.

## Install

```bash
flutter pub add dismissible_page
```

```dart
import 'package:dismissible_page/dismissible_page.dart';
```

## Usage

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
          // Pushes the page without a route background
          context.pushTransparentRoute(SecondPage());
        },
        child: Center(
          child: SizedBox(
            width: 200,
            // Hero is needed to animate the page transition
            child: Hero(
              tag: 'Unique tag',
              child: Image.network(imageUrl, fit: BoxFit.cover),
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
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.all,
      isFullScreen: false,
      child: Hero(
        tag: 'Unique tag',
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
```

### Scrollables

`DismissiblePage` coordinates with inner scrollables and keeps native iOS `BouncingScrollPhysics` and Android `ClampingScrollPhysics` behavior.

- **Implicit**: eligible primary scrollables inherit the controller via `PrimaryScrollController`. Flutter's automatic inheritance depends on platform and scroll axis, and explicit controllers and `PageView` don't use it automatically.
- **Explicit**: use `DismissiblePage.builder` to attach the provided controller yourself.

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

For reliable edge dismissal with `BouncingScrollPhysics`, use the coordinated controller (inherited or supplied by `DismissiblePage.builder`). With an ordinary external `ScrollController`, the notification-only fallback keeps its existing limitation: a bounce can return the page to its origin before the scroll ends, preventing distance-based dismissal.

### Transparent routes

`TransparentRoute` and `pushTransparentRoute` default to a transparent background and 250 ms forward and reverse transitions.

```dart
Navigator.of(context).push(
  TransparentRoute<void>(
    builder: (_) => SecondPage(),
  ),
);
```

They also take `barrierDismissible` (default `true`), `opaque` (default `false`) and a `transitionBuilder` (a fade by default). `onDismissed` stays explicit: `DismissiblePage` doesn't pop a route itself.

## Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `onDismissed` | `VoidCallback` | required | Called when the page has been dismissed |
| `child` | `Widget` | required | Content, or use `DismissiblePage.builder` |
| `controller` | `DismissiblePageScrollController?` | `null` | Coordinates scrollables |
| `direction` | `DismissiblePageDismissDirection` | `all` | Directions the page can be dismissed in |
| `enabled` | `bool` | `true` | If false, dismiss gestures are disabled |
| `isFullScreen` | `bool` | `true` | If true, ignores device padding (`MediaQuery.padding`) |
| `background` | `DismissiblePageBackground` | `transition(from: black, to: transparent)` | Scrim behind the dismissing page |
| `borderRadius` | `DismissiblePageRadius` | `transition()` | Corner radius applied during the drag |
| `gesture` | `DismissiblePageGesture` | `DismissiblePageGesture()` | Thresholds, flings, axis lock and drag region |
| `transform` | `DismissiblePageTransform` | `DismissiblePageTransform()` | Sensitivity, minimum scale and extent of visual effects |
| `motion` | `DismissiblePageMotion` | `DismissiblePageMotion()` | Rebound, exit, dismiss continuation and haptics |
| `onWillDismiss` | `FutureOr<bool> Function()?` | `null` | Asked before dismissing. `false` keeps the page |
| `onDismissStart` | `VoidCallback?` | `null` | Called right before `onDismissed` |
| `onDragStart` / `onDragEnd` / `onDragCancel` | `VoidCallback?` | `null` | Drag lifecycle callbacks |
| `onDragUpdate` | `ValueChanged<DismissiblePageDragUpdateDetails>?` | `null` | Progress, offset, radius, scale and opacity |
| `onDragEvent` | `ValueChanged<DismissiblePageEvent>?` | `null` | One callback for the whole drag lifecycle |
| `dragStartBehavior` | `DragStartBehavior` | `down` | How drag start is handled |
| `hitTestBehavior` | `HitTestBehavior` | `opaque` | How to behave during hit tests |
| `semanticLabel` | `String?` | `null` | Label announced by assistive technologies |

## Guides

<details>
<summary><b>Directional dismissal thresholds</b></summary>

`direction` determines which gestures are allowed. `gesture.dismissThresholds` determines the page displacement required toward each destination side:

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

- Up/down values are fractions of page height, start/end values are fractions of page width. For a 600 px tall page, `down: 0.20` requires 120 px of downward displacement.
- `transform.dragSensitivity` still determines how finger movement translates into page displacement.
- `start` means left in LTR and right in RTL, `end` the opposite. So `startToEnd` uses the `end` threshold and `endToStart` uses the `start` threshold.
- With `all`, a diagonal drag dismisses when either axis reaches its threshold.
- Threshold entries never enable directions excluded by `direction`. Missing sides use `0.18`, and values must be between 0 and 1.
- Fast outward flings can dismiss before a distance threshold is reached, see Motion and haptics under [Guides](#guides).
- Thresholds are independent of `transform.maxTransformValue`, which controls only visual effect progress. `onDragUpdate` exposes that progress as `details.progress` (0 to 1), along with offset, scale, radius and opacity.

</details>

<details>
<summary><b>Gesture</b></summary>

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

`dragRegion` limits both the page's own drag and the pull of a scrollable resting at its edge. The scrollable keeps scrolling normally outside of it. Use `DismissiblePageDragRegion.custom((position, size) => ...)` for any other shape.

</details>

<details>
<summary><b>Transform</b></summary>

`transform` shapes how a drag translates into movement and visual effects:

- `dragSensitivity`: finger to page movement
- `minScale`: scale at maximum drag
- `maxTransformValue`: the fraction of the page at which effects finish

</details>

<details>
<summary><b>Motion and haptics</b></summary>

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

- `DismissiblePageRebound.bouncy()` overshoots the origin slightly, and `DismissiblePageRebound.curve(curve:, duration:)` is the time-based easing. `DismissiblePageRebound` and `DismissiblePageExit` are sealed, so a `switch` over them is exhaustive.
- `exit` applies to a swipe that slides away (`continueOnDismiss`) and to `DismissiblePage.dismiss`. `.momentum()` keeps the release speed, `.curve(curve, duration)` always leaves the same way.
- `continueOnDismiss` leaves the page off-screen, so `onDismissed` is expected to remove it.

**Haptics.** `thresholdHaptics: true` plays a light impact (`HapticFeedback.lightImpact`) each time a drag crosses the dismiss threshold, in either direction.

- **Android** needs the vibrate permission, otherwise the haptic may not play on some devices. Add it to `android/app/src/main/AndroidManifest.xml`, outside the `<application>` element:

  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <uses-permission android:name="android.permission.VIBRATE"/>
      <application ...>
  ```

- **iOS** needs no configuration. On web and desktop the call is a no-op, and devices without a haptic engine, or with system haptics turned off, stay silent.

</details>

<details>
<summary><b>Confirming a dismissal</b></summary>

`onWillDismiss` is asked before a release or `DismissiblePage.dismiss` dismisses the page. Return `false` (or a future completing with `false`) to keep it. While a future is pending, the page is held where it is and ignores further drags.

```dart
DismissiblePage(
  onWillDismiss: () async => await confirmDiscardChanges(context) ?? false,
  onDismissStart: () => debugPrint('leaving'),
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

`onDismissStart` fires right before `onDismissed`, after the confirmation.

</details>

<details>
<summary><b>Following the page</b></summary>

`DismissiblePage.of(context)` (or `maybeOf`) returns a handle with `isDragging`, `isDismissing`, `progress`, `offset` and `dismiss()`. It is a `Listenable`, so a `ListenableBuilder` can follow the drag without wiring `onDragUpdate`:

```dart
ListenableBuilder(
  listenable: DismissiblePage.of(context),
  builder: (context, _) =>
      LinearProgressIndicator(value: DismissiblePage.of(context).progress),
)
```

`onDragEvent` reports the same lifecycle as `onDragStart`, `onDragUpdate`, `onDragEnd` and `onDragCancel` through one callback over the sealed `DismissiblePageEvent`.

</details>

<details>
<summary><b>Custom backgrounds and radii</b></summary>

`DismissiblePageBackground.custom((progress) => color)` and `DismissiblePageRadius.custom((progress) => radius)` compute the value from the drag progress (0 to 1), for transitions the presets can't express.

</details>

<details>
<summary><b>Dismissing from code</b></summary>

`DismissiblePage.dismiss(context)` closes the page with the same motion as a swipe: it winds up slightly, then accelerates off-screen towards `side` (by default the side `direction` dismisses towards) while `onDismissed` runs.

```dart
Builder(
  builder: (context) => IconButton(
    onPressed: () => DismissiblePage.dismiss(context),
    icon: const Icon(Icons.close),
  ),
)
```

The context must be inside the page. Use a `Builder` when the button is built by the widget that creates the `DismissiblePage`.

</details>

<details>
<summary><b>Avoiding accidental dismissals</b></summary>

Dismissing needs clear intent, and the defaults lean towards keeping the page:

- A release past the threshold that drifts back towards the origin (faster than `cancelVelocity`) cancels, even though the page was far enough.
- A fling only dismisses before the threshold when it is fast (`flingVelocity`) and the page has already moved `flingMinDistance`.
- A pull on a scrollable only dismisses the page when the gesture began at that edge. Scrolling quickly to the top and carrying on stays a scroll. Lift and pull again to dismiss.
- `onDragUpdate` reports `details.willDismiss`, true while letting go would dismiss by distance, so you can show a "release to close" hint.

If the page contains something draggable that competes with the dismiss gesture, such as a zoomable image or a slider, set `enabled: false` while it is in use.

</details>

<details>
<summary><b>Accessibility</b></summary>

Screen readers can dismiss the page with their dismiss gesture unless `direction` is `none`. Set `semanticLabel` to announce the page.

</details>

## Migration

<details>
<summary><b>Breaking API changes</b></summary>

- Use `DismissiblePage(child: ...)` or `DismissiblePage.builder(builder: ...)`. Content is required and can't be specified both ways.
- Rename `DismissiblePageDismissDirection.multi` to `.all`.
- Rename `overallDragValue` to `progress`, including constructor arguments and the key returned by `DismissiblePageDragUpdateDetails.toMap()`.
- Replace direction keys in `dismissThresholds` with `DismissiblePageSide` keys. Expand a vertical threshold into up/down entries, horizontal into start/end, and multi into all four sides. Map `startToEnd` to `end` and `endToStart` to `start`.
- Threshold values now measure page displacement rather than visual progress. To preserve an old distance threshold, multiply its effective value by the old `maxTransformValue`. The old default distance was `0.15 * 0.4 = 0.06`, the new default is `0.18` of the page dimension. Diagonal thresholds are evaluated independently for each axis.
- `dragSensitivity`, `minScale` and `maxTransformValue` moved into `transform: DismissiblePageTransform(...)`.
- `dismissThresholds`, `flingVelocity`, `flingMinDistance` and `cancelVelocity` moved into `gesture: DismissiblePageGesture(...)`.
- `reverseDuration` is now `DismissiblePageRebound.curve(duration: ...)`.
- `DismissiblePageRebound` and `DismissiblePageExit` are sealed classes. Test variants with `is DismissiblePageSpringRebound` and so on instead of `isSpring`.
- `DismissiblePageDragUpdateDetails` compares all of its fields, not only `offset`.
- `GlobalKeyExtension.globalPaintBounds` was removed.

`background` and `borderRadius` remain widget arguments.

</details>

## Contributing

PRs are welcome. Target `main`: CI and performance benchmarks run for pull requests targeting `main`, and demo deployment runs on pushes to `main`.

---

<div align="center">

Made by [Tornike](https://www.linkedin.com/in/thornike/) · [Discord](https://rebrand.ly/qwc3s0d) · [Ko-fi](https://ko-fi.com/flutterman) · [Buy Me a Coffee](https://www.buymeacoffee.com/fman) · [MIT License](LICENSE)

If this package helps you, a ⭐ on GitHub means a lot.

</div>
