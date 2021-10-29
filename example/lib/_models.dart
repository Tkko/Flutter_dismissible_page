import 'package:flutter/cupertino.dart';

class StoryModel {
  final storyId = UniqueKey();
  final String title;
  DismissDirection direction;
  String? imageUrl;

  StoryModel({
    required this.title,
    required this.imageUrl,
    this.direction = DismissDirection.down,
  });
}
