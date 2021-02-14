import 'package:example/_models.dart';
import 'package:example/_widgets.dart';
import 'package:flutter/material.dart';

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
