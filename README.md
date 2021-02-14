# dismissible_page

🔥🚀
Creates page that is dismissed by swipe gestures, with Hero style animations, Inspired by FB, IG stories.


## Contents

- [Support](#support)

- [Contribute](#contribute)

- [Overview](#overview)

- [Installation](#installation)

- [Properties](#properties)

- [Example](#example)


## Support
First thing first give it a star ⭐

Discord [Channel](https://discord.gg/ssE8eh)


## Contribute

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## Overview
Creates page that is dismissed by swipe gestures, with Hero style animations, Inspired by FB, IG stories.

<img src="https://raw.githubusercontent.com/Tkko/Flutter_dismissible_page/master/example/media/dismissible_horizontal.gif" width="300em" /> <img src="https://raw.githubusercontent.com/Tkko/Flutter_dismissible_page/master/example/media/dismissible_vertical.gif" width="300em" />

## Installation


### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dismissible_page: ^0.5.5
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```css
$ pub get
```

with `Flutter`:

```css
$ flutter packages get
```

### 3. Import it

Now in your `Dart` code, you can use:

```dart
import 'package:dismissible_page/dismissible_page.dart';
```



## Properties


```dart
  DismissiblePage({
    @required this.child,
    this.isFullScreen = true,
    this.disabled = false,
    this.backgroundColor = Colors.black,
    this.direction = DismissDirection.vertical,
    this.dismissThresholds = const <DismissDirection, double>{},
    this.crossAxisEndOffset = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.initialRadius = 7,
    this.onDismiss,
    this.onDragStart,
    this.onDragEnd,
    Key key,
  })  : assert(dragStartBehavior != null),
        super(key: key);
```

## Example

Import the package:

```dart
import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(AppView());

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: AppHome());
}

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final stories = [
    StoryModel(title: 'STORY'),
    StoryModel(title: 'STORY'),
    StoryModel(title: 'STORY'),
    StoryModel(title: 'STORY'),
    StoryModel(title: 'STORY'),
    StoryModel(title: 'STORY'),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Dismissible', style: TextStyle(fontSize: 24)),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, int i) => StoryWidget(story: stories[i]),
                separatorBuilder: (_, int i) => SizedBox(width: 10),
                itemCount: stories.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class StoryWidget extends StatelessWidget {
  final StoryModel story;

  const StoryWidget({this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushTransparentRoute(StoryPage(story: story));
      },
      child: Hero(
        tag: story.storyId,
        child: Container(
          height: 120,
          width: 88,
          padding: const EdgeInsets.all(8),
          child: Text(
            story.title,
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(color: Colors.white),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(story.imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}


class StoryPage extends StatelessWidget {
  final StoryModel story;
  const StoryPage({this.story});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismiss: () => Navigator.of(context).pop(),
      isFullScreen: false,
      child: Material(
        color: Colors.transparent,
        child: Hero(
          tag: story.storyId,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              story.title,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.white),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(story.imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryModel {
  final storyId = UniqueKey();
  final String title;
  String imageUrl;

  String get nextVehicleUrl =>
      'https://source.unsplash.com/collection/1989985/${Random().nextInt(20) + 400}x${Random().nextInt(20) + 800}';

  StoryModel({this.title, this.imageUrl}) {
    imageUrl = nextVehicleUrl;
  }
}
```
