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
    this.isFullScreen = true,
    this.enabled = true,
    this.background = const DismissiblePageBackground.transition(
      from: Colors.black,
      to: Colors.transparent,
    ),
    this.borderRadius = const DismissiblePageRadius.transition(),
    this.direction = DismissiblePageDismissDirection.vertical,
    this.dismissThresholds = const <DismissiblePageSide, double>{},
    this.dragStartBehavior = DragStartBehavior.down,
    this.dragSensitivity = 0.7,
    this.minScale = .85,
    this.maxTransformValue = .4,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
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

  /// If true widget will ignore device padding
  /// [MediaQuery.of(context).padding]
  final bool isFullScreen;

  /// If false, dismiss gesture interactions are disabled.
  final bool enabled;

  /// Configuration for the background scrim behind the dismissing widget.
  final DismissiblePageBackground background;

  /// Configuration for the corner radius applied to the content during drag.
  final DismissiblePageRadius borderRadius;

  /// The minimum amount of scale widget can have while dragging
  /// Note that scale decreases as user drags
  final double minScale;

  /// Fraction of page dimension at which visual effects reach their final values.
  /// Does not cap translation or affect dismissal thresholds.
  final double maxTransformValue;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// Page displacement thresholds per destination side (0.0 - 1.0).
  /// Missing sides default to 0.15.
  final Map<DismissiblePageSide, double> dismissThresholds;

  /// Represents how much responsive dragging the widget will be
  final double dragSensitivity;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  /// The amount of time the widget will spend returning to initial position if widget is not dismissed after drag
  final Duration reverseDuration;

  /// How to behave during hit tests.
  ///
  /// This defaults to [HitTestBehavior.opaque].
  final HitTestBehavior hitTestBehavior;
```

## Directional dismissal thresholds

`direction` determines which gestures are allowed. `dismissThresholds` determines
the required page displacement toward each destination side:

```dart
DismissiblePage(
  direction: DismissiblePageDismissDirection.all,
  dismissThresholds: const {
    DismissiblePageSide.up: 0.10,
    DismissiblePageSide.down: 0.20,
    DismissiblePageSide.start: 0.30,
    DismissiblePageSide.end: 0.40,
  },
  onDismissed: () => Navigator.of(context).pop(),
  child: const SizedBox.expand(),
)
```

Up/down values are fractions of page height; start/end values are fractions of
page width. For a 600 px tall page, `down: 0.20` requires 120 px of downward page
displacement. `dragSensitivity` still determines how finger movement translates
into page displacement.

`start` means left in LTR and right in RTL; `end` means right in LTR and left in
RTL. Consequently, `startToEnd` uses the `end` threshold and `endToStart` uses
the `start` threshold. With `all`, a diagonal drag dismisses when either axis
reaches its corresponding threshold. Threshold entries never enable directions
excluded by `direction`. Missing sides use 0.15; values must be between 0 and 1.
Fast outward flings can dismiss before a distance threshold is reached.

Thresholds are independent of `maxTransformValue`, which controls only visual
effect progress. `onDragUpdate` exposes this visual progress as `details.progress`
(0 to 1), along with offset, scale, radius, and opacity.

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
  the new default is `0.15` of the page dimension. Diagonal thresholds are
  evaluated independently for each axis.

Styling stays flat: `background`, `borderRadius`, `minScale`, and
`maxTransformValue` remain widget arguments.
