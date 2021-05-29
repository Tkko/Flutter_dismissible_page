import 'dart:math';
import 'package:flutter/cupertino.dart';

class StoryModel {
  final storyId = UniqueKey();
  final String title;
  String? imageUrl;

  String get nextVehicleUrl =>
      'https://source.unsplash.com/collection/1989985/${Random().nextInt(20) + 400}x${Random().nextInt(20) + 800}';

  StoryModel({required this.title,  this.imageUrl}) {
    imageUrl = nextVehicleUrl;
  }
}
