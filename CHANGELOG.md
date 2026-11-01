## 2.0.0-beta.1

### Breaking Changes
- Require `child` on `DismissiblePage` and move builder content to `DismissiblePage.builder`.
- Rename `DismissiblePageDismissDirection.multi` to `DismissiblePageDismissDirection.all`.
- Rename `overallDragValue` to `progress` in `DismissiblePageDragUpdateDetails` (including `toMap()`).
- Key `dismissThresholds` by directional destination sides (`DismissiblePageSide.up`, `down`, `start`, `end`) instead of directions. Missing sides default to `0.15`.
- Updated minimum SDK constraints to Dart `>=3.0.0 <5.0.0` and Flutter `>=3.10.0`.

### New Features & Enhancements
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

### Example
```dart
// Standard widget usage with new properties:
DismissiblePage(
  onDismissed: () => Navigator.of(context).pop(),
  direction: DismissiblePageDismissDirection.all, // renamed from .multi
  dismissThresholds: const {
    DismissiblePageSide.down: 0.2, // keyed by DismissiblePageSide
  },
  background: DismissiblePageBackground.fadeOut(Colors.black),
  borderRadius: const DismissiblePageRadius.transition(from: 0.0, to: 28.0),
  onDragCancel: () => debugPrint('Cancelled'),
  onDragUpdate: (details) => debugPrint('Progress: ${details.progress}'),
  child: const MyPageContent(),
)

// With explicit scroll coordination:
DismissiblePage.builder(
  onDismissed: () => Navigator.of(context).pop(),
  builder: (context, controller) => ListView(
    controller: controller,
    children: [...],
  ),
)
```

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
