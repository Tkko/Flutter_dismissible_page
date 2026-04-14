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

## Why This Fork Exists

This fork focuses on fixing long-standing scroll + dismiss gesture conflicts in
`DismissiblePage`, especially for pages that contain scrollable content.

### What It Fixes

- Introduces a custom `ScrollController` + `ScrollPosition` arbitration path
  for `interactionMode: DismissiblePageInteractionMode.scroll`.
- Ensures drag delta is routed correctly between page dismissal and inner
  scrollable content.
- Fixes the issue where reversing direction could leave the page in a dismiss
  state or leak part of the delta into dismiss drag unexpectedly.

### Behavior Comparison

Old behavior (problematic):

https://user-images.githubusercontent.com/26390946/194924545-1712b63b-2a25-4182-b731-db49ecc50c23.mov

New behavior (expected):

https://github.com/user-attachments/assets/9ef89285-7d6a-45f9-87aa-d589d8d89c5e

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
| [Live Demo](https://rebrand.ly/gw8nktq) | Multi Direction | Vertical |
|--|--|--|
| <a href="https://rebrand.ly/gw8nktq"><img width="300" src="https://user-images.githubusercontent.com/26390946/156333539-29aefaf2-5f42-4414-8d8c-1ecbae40c377.png"/></a> | <img src="https://user-images.githubusercontent.com/26390946/161377483-78e5dbaf-678f-4381-a393-52af8180bbcb.gif" /> | <img src="https://user-images.githubusercontent.com/26390946/156391449-a9235d05-bc87-4f51-8a5d-50c44fd0c582.gif"/> |

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
      interactionMode: DismissiblePageInteractionMode.scroll,
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Hero(
          tag: 'Unique tag',
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

## Properties

``` dart
  const DismissiblePage({
    required this.builder,
    required this.onDismissed,
    required this.interactionMode,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.isFullScreen = true,
    this.disabled = false,
    this.backgroundColor = Colors.black,
    this.direction = DismissiblePageDismissDirection.vertical,
    this.dismissThresholds = const <DismissiblePageDismissDirection, double>{},
    this.dragStartBehavior = DragStartBehavior.down,
    this.dragSensitivity = 0.7,
    this.minRadius = 7,
    this.minScale = .85,
    this.maxRadius = 30,
    this.maxTransformValue = .4,
    this.startingOpacity = 1,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    Key? key,
  }) : super(key: key);

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Controls scroll-aware dismissal behavior.
  final DismissiblePageInteractionMode interactionMode;

  /// Called when the user starts dragging the widget.
  final VoidCallback? onDragStart;

  /// Called when the user ends dragging the widget.
  final VoidCallback? onDragEnd;

  /// Called when the widget has been dragged. (0.0 - 1.0)
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  /// If true widget will ignore device padding
  /// [MediaQuery.paddingOf(context)]
  final bool isFullScreen;

  /// The minimum amount of scale widget can have while dragging
  /// Note that scale decreases as user drags
  final double minScale;

  /// The minimum amount fo border radius widget can have
  final double minRadius;

  /// The maximum amount of border radius widget can have while dragging
  /// Note that radius increases as user drags
  final double maxRadius;

  /// The amount of distance widget is able to drag. value (0.0 - 1.0)
  final double maxTransformValue;

  /// If true the widget will ignore gestures
  final bool disabled;

  /// Builder that receives a [ScrollController] for scroll-aware mode.
  final DismissiblePageBuilder builder;

  /// Background color of [DismissiblePage]
  final Color backgroundColor;

  /// The amount of opacity [backgroundColor] will have when start dragging the widget.
  final double startingOpacity;

  /// Whether to enable background opacity animation.
  final bool enableBackgroundOpacity;

  /// The minimum opacity of the background when the page is displayed.
  final double minOpacity;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed. default is [_kDismissThreshold], value (0.0 - 1.0)
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;

  /// Represents how much responsive dragging the widget will be
  /// Doesn't work on [DismissiblePageDismissDirection.multi]
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

