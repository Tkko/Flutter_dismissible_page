import 'package:example/_models.dart';
import 'package:example/_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(AppView());

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: Container(
            margin: EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 20,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: MaterialApp(
              theme: ThemeData(
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: AppBarTheme(
                    color: Colors.white,
                  )),
              home: AppHome(),
            ),
          ),
        ),
      );
}

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  DismissDirection direction = DismissDirection.down;
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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Dismissible',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Dismiss Direction', style: TextStyle(fontSize: 24)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: DismissDirection.values.map((item) {
                return ChoiceChip(
                  onSelected: (_) {
                    setState(() => direction = item);
                  },
                  selected: item == direction,
                  label: Text(
                    '$item'.replaceAll('DismissDirection.', '').toUpperCase(),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Stories', style: TextStyle(fontSize: 24)),
          ),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, int i) => StoryWidget(
                story: stories[i]..direction = direction,
              ),
              separatorBuilder: (_, int i) => SizedBox(width: 10),
              itemCount: stories.length,
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
