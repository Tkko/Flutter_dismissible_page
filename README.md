<div align="center">
  <h1 align="center" style="font-size: 70px;">Flutter Pinput From <a href="https://www.linkedin.com/in/thornike/" target="_blank">Tornike</a> </h1>

<a href="https://www.buymeacoffee.com/fman" target="_blank"><img src="https://img.buymeacoffee.com/button-api/?text=Thank me with a coffee&emoji=&slug=fman&button_colour=40DCA5&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=FFDD00"></a>

</div>

Flutter package to navigate to page that is dismissed by swipe gestures, with Hero style animations, Inspired by FB, IG stories.

  
## Features:
-    Dismiss to any direction
-    Animating border
-    Animating background
-    Animating scale
  

## Support
PRs Welcome
Discord [Channel](https://discord.gg/gw8nktq)
Don't forget to give it a star ⭐
  
| [Live Demo](https://rebrand.ly/6390b8) | Vertical | Horizontal |
|--|--|--|
| <a href="https://rebrand.ly/6390b8"> ![Live Demo](https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png) <a/> | ![Vertical](https://raw.githubusercontent.com/Tkko/Flutter_dismissible_page/master/example/media/dismissible_horizontal.gif) | ![Horizontal](https://raw.githubusercontent.com/Tkko/Flutter_dismissible_page/master/example/media/dismissible_vertical.gif) |

  
## Getting Started
 Navigate to desired page
```dart
const imageUrl =
    'https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png';
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          context.pushTransparentRoute(SecondPage());
        },
        child: Center(
          child: SizedBox(
            width: 200,
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
```


```dart
const imageUrl =
    'https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png';
class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismiss: () {
        Navigator.of(context).pop();
      },
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


  
## Installation  
  
Add this to your package's `pubspec.yaml` file:  
  
```yaml  
dependencies:  
  dismissible_page: ^0.6.5
```  
You can install packages from the command line:  
  
```css  
$ flutter packages get  
```  
  
Now in your `Dart` code, you can use:  
  
```dart  
import 'package:dismissible_page/dismissible_page.dart';
```  
  
## Properties  

``` dart
  const DismissiblePage({
    required this.child,
    required this.onDismissed,
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
    this.behavior = HitTestBehavior.opaque,
    this.reverseDuration = const Duration(milliseconds: 200),
    Key? key,
  }) : super(key: key);

  /// Called when the widget has been dismissed.
  final VoidCallback onDismissed;

  /// Called when the user starts dragging the widget.
  final VoidCallback? onDragStart;

  /// Called when the user ends dragging the widget.
  final VoidCallback? onDragEnd;

  /// Called when the user drags the widget. [0.0 - 1.0]
  final ValueChanged<double>? onDragUpdate;

  /// If true widget will ignore device padding
  /// [MediaQuery.of(context).padding]
  final bool isFullScreen;

  /// The minimum amount of scale widget can have while dragging
  /// Note that scale decreases as user drags
  final double minScale;

  /// The minimum amount fo border radius widget can have
  final double minRadius;

  /// The maximum amount of border radius widget can have while dragging
  /// Note that radius increases as user drags
  final double maxRadius;

  /// The amount of distance widget is able to drag. value [0.0 - 1.0]
  final double maxTransformValue;

  /// If true the widget will ignore gestures
  final bool disabled;

  /// Widget that should be dismissed
  final Widget child;

  /// Background color of [DismissiblePage]
  final Color backgroundColor;

  /// The amount of opacity [backgroundColor] will have when start dragging the widget.
  final double startingOpacity;

  /// The direction in which the widget can be dismissed.
  final DismissiblePageDismissDirection direction;

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed. default is [_kDismissThreshold], value [0.0 - 1.0]
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
  final HitTestBehavior behavior;
```

