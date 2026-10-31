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
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
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
- **Zero Configuration**: Any `ListView`, `GridView`, or `CustomScrollView` passed to `child:` automatically inherits the controller via `PrimaryScrollController`.
- **Builder pattern**: Use `builder: (context, controller)` to explicitly attach `controller` to your scrollable.
- **Authentic Scroll Physics**: Works natively with both iOS `BouncingScrollPhysics` and Android `ClampingScrollPhysics`. Inner scroll momentum, bounce, and deceleration remain 100% authentic.

```dart
DismissiblePage(
  onDismissed: () => Navigator.of(context).pop(),
  builder: (context, controller) => ListView.builder(
    controller: controller,
    itemCount: 50,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
)
```

## Properties

``` dart
  const DismissiblePage({
    required this.onDismissed,
    this.controller,
    this.child,
    this.builder,
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
    this.dismissThresholds = const <DismissiblePageDismissDirection, double>{},
    this.dragStartBehavior = DragStartBehavior.down,
    this.dragSensitivity = 0.7,
    this.minScale = .85,
    this.maxTransformValue = .4,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    super.key,
  });

  /// An optional [DismissiblePageScrollController] for coordinating scrollables.
  final DismissiblePageScrollController? controller;

  /// The widget below this widget in the tree.
  final Widget? child;

  /// A builder function providing a [DismissiblePageScrollController].
  final Widget Function(BuildContext context, DismissiblePageScrollController controller)? builder;

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

  /// The amount of distance widget is able to drag. value (0.0 - 1.0)
  final double maxTransformValue;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed. default is [_kDismissThreshold], value (0.0 - 1.0)
  final Map<DismissiblePageDismissDirection, double> dismissThresholds;

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

