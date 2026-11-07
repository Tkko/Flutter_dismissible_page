## 2.1.0

### Scroll Coordination & Performance
- Fixed `BouncingScrollPhysics` dismissing the page while scrolling with a `DismissiblePageScrollController`. The page also handled the scroll notifications of its own controller, so a drag could move it twice, and pushing back after crossing the top edge could lift the page past its origin and dismiss it.
- Fixed the page being dismissed while scrolling a list that is not driven by the page's controller, with any scroll physics. A scroll back towards the origin now stops the page there instead of carrying it through to the other side, and pushing a list out of its overscroll no longer moves the page.
- A list that bounces no longer overscrolls under a displaced page: it stops at the edge and the page takes the rest of the drag. Grabbing a list during a bounce now stays with the bounce, and the next pull moves the page.

## 2.0.0

See the [Migration](README.md#migration) section of the README for upgrade steps.

### Breaking Changes
- Require `child` on `DismissiblePage` and move builder content to `DismissiblePage.builder`.
- Rename `DismissiblePageDismissDirection.multi` to `DismissiblePageDismissDirection.all`. `direction` now defaults to `all` (was `vertical`); pass `direction: DismissiblePageDismissDirection.vertical` to keep the previous behavior.
- Rename `overallDragValue` to `progress` in `DismissiblePageDragUpdateDetails` (including `toMap()`).
- Key `dismissThresholds` by directional destination sides (`DismissiblePageSide.up`, `down`, `start`, `end`) instead of directions. Missing sides default to `0.18` of the page dimension.
- Group `dragSensitivity`, `minScale` and `maxTransformValue` into `transform: DismissiblePageTransform`, and `dismissThresholds` into `gesture: DismissiblePageGesture`. The range checks live in these classes.
- Remove `reverseDuration`; use `DismissiblePageRebound.curve(duration: ...)`.
- Remove `GlobalKeyExtension.globalPaintBounds`.
- `DismissiblePageDragUpdateDetails` now compares and hashes all of its fields instead of only `offset`.
- Updated minimum SDK constraints to Flutter `>=3.27.0` and Dart `^3.6.0`, to match Flutter's modernized `Color` APIs (`Color.withValues()`, `Color.a`).

### New Features & Enhancements
- **`DismissiblePage.of(context)` / `maybeOf`**: A `DismissiblePageHandle` with `isDragging`, `isDismissing`, `progress`, `offset` and `dismiss()`. It is a `Listenable`, so UI can follow the drag.
- **`onWillDismiss`**: Confirm or veto a dismissal, synchronously or with a future that holds the page while it is pending. Applies to released drags and `DismissiblePage.dismiss`.
- **`onDismissStart`**: Called right before `onDismissed`, after the confirmation.
- **`onDragEvent`**: One callback over the sealed `DismissiblePageEvent` for the whole drag lifecycle.
- **`DismissiblePageGesture`**: Decides what counts as a dismissing drag: `dismissThresholds`, `flingVelocity` and `flingMinDistance` (how fast, and from how far, a fling dismisses the page), and `cancelVelocity` (default 300, how little speed back towards the origin cancels a release that is past the threshold, so cancelling needs only a hint while dismissing needs intent).
- **`DismissiblePageGesture.lockAxis`**: With `DismissiblePageDismissDirection.all`, a drag sticks to the axis it started along.
- **`DismissiblePageGesture.dragRegion`**: Limit where a drag may start (`.edge`, `.custom`), for example a top strip only. Each finger is judged on its own, trackpad gestures included, and a page that is displaced by a drag or rebound is hit where it is seen.
- **`DismissiblePageMotion`**: New `motion` parameter that tunes released drags. `rebound` picks `DismissiblePageRebound.spring()` (default, seeded with the release velocity), `.bouncy()` or `.curve(curve:, duration:)`. `continueOnDismiss` keeps the page moving off-screen from the finger while `onDismissed` runs, and `thresholdHaptics` fires a light haptic when the dismiss threshold is crossed (Android needs the `VIBRATE` permission in its manifest, see the README).
- **`DismissiblePageExit`**: `motion.exit` chooses how the page leaves the screen: `.momentum()` (default) carries the release velocity, and `.curve(curve, duration)` always leaves along that curve and duration. It applies to a swipe exit (with `continueOnDismiss`) and to `DismissiblePage.dismiss`. `DismissiblePageRebound` and `DismissiblePageExit` are sealed classes, so a `switch` over their variants is exhaustive.
- **`DismissiblePage.dismiss(context, {side})`**: Dismiss from code with the same motion as a swipe. The page winds up slightly, then accelerates off-screen towards `side` (by default the side `direction` dismisses towards) while `onDismissed` runs, so close buttons no longer only fade.
- **`DismissiblePageDragUpdateDetails.willDismiss`**: True while letting go would dismiss by distance, for "release to close" hints.
- **Safer scroll hand-off**: A pull on a scrollable only dismisses the page when the gesture began at that edge. Scrolling quickly to the top and carrying on is a scroll, not a dismissal, and a new pull from the top dismisses as before.
- **Accessibility**: Screen readers get a dismiss action, and `semanticLabel` names the page.
- **`TransparentRoute` options**: `barrierDismissible`, `opaque` and `transitionBuilder` (also on `pushTransparentRoute`).
- **`DismissiblePageBackground.custom` / `DismissiblePageRadius.custom`**: Compute the value from the drag progress.
- **`DismissiblePageBackground`**: Introduced a structured class with `.color()`, `.widget()`, and `.custom()` factories for animated background rendering and opacity blending.
- **`DismissiblePageRadius`**: Introduced a dedicated model (`.circular()`, `.all()`, etc.) for managing corner radius transformations during drag interactions.
- **`onDragCancel` callback**: Added callback invoked when a drag gesture is cancelled or released without triggering a dismissal.
- **`maxTransformValue: 0` support**: Allows scaling and opacity effects without spatial translation.
- **Trackpad gesture support**: Added trackpad support as a pointer drag device alongside touch and stylus.
- **Discrete mouse wheel filtering**: Pointer wheel scrolls no longer trigger dismiss gestures on desktop and web.
- **Configuration assertions**: Added runtime assertions for scalar configuration parameters (`minScale`, `maxRadius`, `minRadius`, `maxTransformValue`, and dismiss thresholds) for faster bug detection during development.
- **`TransparentRoute` updates**: Default transparent background and streamlined 250 ms forward/reverse transition durations.

### Scroll Coordination & Performance
- **Universal scroll arbiter**: Introduced `DismissiblePageArbiter` to smoothly coordinate nested scrollables (`ListView`, `GridView`, `CustomScrollView`, `SingleChildScrollView`) without requiring explicit listeners.
- **Edge cases & RTL support**: Resolved scroll-edge deltas in screen coordinates so directional dismiss thresholds work correctly with reverse axes and RTL text directions.
- **Optimized drag rendering**: Reduced unnecessary widget rebuilds during drag gestures by isolating visual updates (transform, opacity, border radius).
- **Controller lifecycle**: Properly preserve and dispose internally owned scroll controllers for disabled builder content.

### Tooling, Tests & CI/CD
- Added comprehensive integration test suite (`dismissible_flow_test.dart`).
- Added performance benchmarking suite (`run_perf_benchmarks.sh`, `perf_driver.dart`, `benchmarks.yml`) measuring raster and frame build times.
- Automated CI testing across platforms and pub.dev OIDC publishing workflow.
- Updated example app with cross-platform support (Android, iOS, macOS, Windows, Linux, Web).
- Modernized codebase to `very_good_analysis ^11.0.0` and Flutter's `Color.withValues()` API.

### Closed Issues
- [#14](https://github.com/Tkko/Flutter_dismissible_page/issues/14) Not working with `CustomScrollView`
- [#32](https://github.com/Tkko/Flutter_dismissible_page/issues/32) `ListView` behaviour while being dismissed
- [#33](https://github.com/Tkko/Flutter_dismissible_page/issues/33) `BouncingScrollPhysics` mode does not work inside `DismissiblePage`
- [#36](https://github.com/Tkko/Flutter_dismissible_page/issues/36) Inner scrollable also scrolls while reversing the dismissal
- [#37](https://github.com/Tkko/Flutter_dismissible_page/issues/37) Add `onDragCancel` callback

### Pull Requests
[#41](https://github.com/Tkko/Flutter_dismissible_page/pull/41), [#42](https://github.com/Tkko/Flutter_dismissible_page/pull/42), [#43](https://github.com/Tkko/Flutter_dismissible_page/pull/43), [#44](https://github.com/Tkko/Flutter_dismissible_page/pull/44), [#46](https://github.com/Tkko/Flutter_dismissible_page/pull/46), [#52](https://github.com/Tkko/Flutter_dismissible_page/pull/52), [#53](https://github.com/Tkko/Flutter_dismissible_page/pull/53), [#54](https://github.com/Tkko/Flutter_dismissible_page/pull/54)

## 1.0.3
- Fixed unexpected behavior of dismissing the page when user is scrolling the opposite direction [Issue](https://github.com/Tkko/Flutter_dismissible_page/issues/14#issuecomment-1599097053)

## 1.0.2
- Merged Fix mixins of _MultiAxisDismissiblePageState (PR)[https://github.com/Tkko/Flutter_dismissible_page/pull/25]
- Fixed main example
- Fixed package title in README.md
- Bumped version

## 1.0.1
- Nothing special, the formatter, messed up the readme, so I had to update it

## 1.0.0
- From now on you can use Dismissible page with scrollable content
- Added pub screenshots


## 0.7.3
- Implemented [onDragUpdate](https://github.com/Tkko/Flutter_dismissible_page/issues/15) 


## 0.7.2
- rootNavigator [PR](https://github.com/Tkko/Flutter_dismissible_page/pull/13)


## 0.7.1
- Fixed disabled Dismissible
- Improved readme


## 0.7.0 -02/03/2022
- Added Multi direction dismiss
- Improved example
- Improved readme


## 0.6.5 -19/02/2022
- Removed media from pub
- Merged [PR 9](https://github.com/Tkko/Flutter_dismissible_page/pull/9)
    - Added
        | Property  | Default |
        | ------------- | ------------- |
        | transitionDuration  |  Duration(milliseconds: 250) |
        | reverseTransitionDuration  |  Duration(milliseconds: 250) |
- Improved Example App


## 0.6.4 -27/10/2021
Closed issues:

 - [Disabled background](https://github.com/Tkko/Flutter_dismissible_page/issues/5#issue-964593191)
 - [Animation speed](https://github.com/Tkko/Flutter_dismissible_page/issues/6#issue-1037569113)


🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| dragSensitivity  |  Duration(milliseconds: 500) |

## 0.6.3 -29/05/2021
🔥🚀
Quick fix


## 0.6.2 -29/05/2021
🔥🚀
Migrated to Null safety


0.6.1 -14/02/2021
🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| reverseDuration  |  Duration(milliseconds: 500) |


## 0.6.0 -14/02/2021
🔥🚀
Added
| Property  | Default |
| ------------- | ------------- |
| minScale  | .85 |
| minRadius  | 7 |
| maxRadius  | 30 |
| maxTransformValue  | .4 |


## 0.5.5 -14/02/2021
🔥🚀
Removed unused code
Added Demos

## 0.5.0 -14/02/2021
🔥🚀
Initial version of package. base functionality works properly
