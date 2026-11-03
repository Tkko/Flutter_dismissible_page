import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ReboundKind { spring, bouncy, curve, custom }

/// The exit animations the Motion Lab offers.
enum ExitKind {
  momentum('Momentum', 'DismissiblePageExit.momentum()'),
  ease(
    'Ease',
    'DismissiblePageExit.curve(\n'
        '        Curves.easeInOutCubic,\n'
        '        duration: Duration(milliseconds: 320),\n'
        '      )',
  ),
  windUp(
    'Wind-up',
    'DismissiblePageExit.curve(\n'
        '        Curves.easeInBack,\n'
        '        duration: Duration(milliseconds: 360),\n'
        '      )',
  ),
  snap(
    'Snap',
    'DismissiblePageExit.curve(\n'
        '        Curves.easeIn,\n'
        '        duration: Duration(milliseconds: 180),\n'
        '      )',
  );

  const ExitKind(this.label, this.code);

  final String label;

  /// The same exit as Dart source, for the Motion Lab's "Copy as code".
  final String code;

  DismissiblePageExit get exit => switch (this) {
        ExitKind.momentum => const DismissiblePageExit.momentum(),
        ExitKind.ease => const DismissiblePageExit.curve(
            Curves.easeInOutCubic,
            duration: Duration(milliseconds: 320),
          ),
        ExitKind.windUp => const DismissiblePageExit.curve(
            Curves.easeInBack,
            duration: Duration(milliseconds: 360),
          ),
        ExitKind.snap => const DismissiblePageExit.curve(
            Curves.easeIn,
            duration: Duration(milliseconds: 180),
          ),
      };
}

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
      DismissiblePageDismissDirection.all;
  Map<DismissiblePageSide, double> dismissThresholds =
      const <DismissiblePageSide, double>{};
  DragStartBehavior dragStartBehavior = DragStartBehavior.down;
  Duration reverseDuration = const Duration(milliseconds: 200);
  HitTestBehavior behavior = HitTestBehavior.opaque;
  ReboundKind reboundKind = ReboundKind.spring;
  ExitKind exitKind = ExitKind.momentum;
  double stiffness = 900;
  double dampingRatio = 1.0;
  double dismissThreshold = 0.18;
  double flingVelocity = 1000;
  double cancelVelocity = 300;
  double flingMinDistance = 0.1;
  bool continueOnDismiss = true;
  bool thresholdHaptics = true;

  /// Picks a rebound, loading the spring numbers its preset stands for.
  void selectRebound(ReboundKind kind) {
    reboundKind = kind;
    switch (kind) {
      case ReboundKind.spring:
        stiffness = 900;
        dampingRatio = 1.0;
      case ReboundKind.bouncy:
        stiffness = 900;
        dampingRatio = 0.65;
      case ReboundKind.curve || ReboundKind.custom:
        break;
    }
  }

  /// Sets the dismiss distance of every side at once.
  void setDismissThreshold(double value) {
    dismissThreshold = value;
    dismissThresholds = {
      for (final side in DismissiblePageSide.values) side: value,
    };
  }

  DismissiblePageMotion get motion => motionWith();

  /// The current motion, optionally forcing [continueOnDismiss]. Screens that
  /// leave through a Hero turn it off, because the flight is their exit.
  DismissiblePageMotion motionWith({bool? continueOnDismiss}) =>
      DismissiblePageMotion(
        rebound: reboundKind == ReboundKind.curve
            ? const DismissiblePageRebound.curve()
            : DismissiblePageRebound.spring(
                stiffness: stiffness,
                dampingRatio: dampingRatio,
              ),
        exit: exitKind.exit,
        continueOnDismiss: continueOnDismiss ?? this.continueOnDismiss,
        thresholdHaptics: thresholdHaptics,
        flingVelocity: flingVelocity,
        cancelVelocity: cancelVelocity,
        flingMinDistance: flingMinDistance,
      );
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
