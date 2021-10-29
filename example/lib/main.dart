import 'dart:ui';

import 'package:example/_models.dart';
import 'package:example/_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(AppView());

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final app = MaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(color: Colors.white),
          ),
          home: AppHome(),
        );
        if (constraints.maxWidth > 600 && constraints.maxHeight > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: .5,
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
                child: app,
              ),
            ),
          );
        }
        return app;
      },
    );
  }
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
  ];
  final contacts = {
    'GitHub': 'https://github.com/Tkko',
    'LinkedIn': 'https://www.linkedin.com/in/thornike/',
    'Pub': 'https://pub.dev/publishers/fman.ge/packages',
    'Medium': 'https://thornike.medium.com/',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Contact me', style: TextStyle(fontSize: 24)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: contacts.entries.map((item) {
                return ActionChip(
                  onPressed: () => launch(item.value),
                  label: Text(item.key),
                );
              }).toList(),
            ),
          ),
          Spacer(),
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
                    '$item'.replaceAll('DismissDirection.', ''),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Stories', style: TextStyle(fontSize: 24)),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final width = constraints.maxWidth;
              final itemHeight = width / 3;
              final itemWidth = width / 4;
              return SizedBox(
                height: itemHeight,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, int i) {
                    return SizedBox(
                      width: itemWidth,
                      child: StoryWidget(
                        story: stories[i]..direction = direction,
                        stories: stories,
                      ),
                    );
                  },
                  separatorBuilder: (_, int i) => SizedBox(width: 10),
                  itemCount: stories.length,
                ),
              );
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
