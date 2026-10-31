import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DismissiblePageModel {
  static const List<String> naturePhotos = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=600&auto=format&fit=crop&q=80',
  ];

  static const List<String> foodPhotos = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600&auto=format&fit=crop&q=80',
  ];

  DismissiblePageModel() {
    stories = [
      StoryModel(title: 'Random', imageUrl: naturePhotos[0]),
      StoryModel(title: 'Photos', imageUrl: naturePhotos[1]),
      StoryModel(title: 'From', imageUrl: foodPhotos[0]),
      StoryModel(title: 'Unsplash', imageUrl: naturePhotos[2]),
    ];
  }

  String get randomFood => foodPhotos[Random().nextInt(foodPhotos.length)];

  String get randomNature =>
      naturePhotos[Random().nextInt(naturePhotos.length)];

  List<StoryModel> stories = [];
  final contacts = {
    'GitHub': 'https://github.com/Tkko',
    'LinkedIn': 'https://www.linkedin.com/in/thornike/',
    'Pub': 'https://pub.dev/publishers/tornike.dev/packages',
  };

  Duration transitionDuration = const Duration(milliseconds: 250);
  Duration reverseTransitionDuration = const Duration(milliseconds: 250);
  bool isFullScreen = true;
  bool enabled = true;
  double minScale = .85;
  double maxTransformValue = .5;
  double dragSensitivity = .7;
  DismissiblePageBackground background =
      const DismissiblePageBackground.transition(
    from: Colors.black,
    to: Colors.transparent,
  );
  DismissiblePageRadius borderRadius =
      const DismissiblePageRadius.transition(from: 7, to: 30);
  DismissiblePageDismissDirection direction =
      DismissiblePageDismissDirection.vertical;
  Map<DismissiblePageDismissDirection, double> dismissThresholds =
      const <DismissiblePageDismissDirection, double>{};
  DragStartBehavior dragStartBehavior = DragStartBehavior.down;
  Duration reverseDuration = const Duration(milliseconds: 200);
  HitTestBehavior behavior = HitTestBehavior.opaque;
}

class StoryModel {
  final String altUrl = 'assets/images/photo_not_found.png';
  final storyId = UniqueKey();
  final String title;
  final String imageUrl;

  StoryModel({
    required this.title,
    required this.imageUrl,
  });
}
