import 'dart:math';
import 'dart:ui';
import 'package:example/models.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() => runApp(AppView());

const accentColor = Color(0xff00d573);

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: accentColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(color: Colors.white),
            chipTheme: ChipThemeData(selectedColor: accentColor),
            sliderTheme: SliderThemeData(
              activeTrackColor: accentColor,
              activeTickMarkColor: accentColor,
              thumbColor: accentColor,
              inactiveTrackColor: accentColor.withOpacity(.2),
            ),
          ),
          home: AppHome(),
        );

        final shortestSide =
            min(constraints.maxWidth.abs(), constraints.maxHeight.abs());

        if (shortestSide > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'Dismissible Example',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 400,
                  height: 900,
                  margin: EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 15),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: app,
                ),
              ],
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
  String get randomFood =>
      'https://source.unsplash.com/collection/1424340/${Random().nextInt(20) + 400}x${Random().nextInt(20) + 600}';

  String get randomNature =>
      'https://source.unsplash.com/collection/1319040/${Random().nextInt(20) + 400}x${Random().nextInt(20) + 600}';

  DismissDirection direction = DismissDirection.down;
  Duration transitionDuration = const Duration(milliseconds: 250);
  Duration reverseTransitionDuration = const Duration(milliseconds: 250);
  final List<StoryModel> stories = [];
  final contacts = {
    'GitHub': 'https://github.com/Tkko',
    'LinkedIn': 'https://www.linkedin.com/in/thornike/',
    'Medium': 'https://thornike.medium.com/',
    'Pub': 'https://pub.dev/publishers/fman.ge/packages',
  };

  @override
  void initState() {
    stories.addAll([
      StoryModel(title: 'Random'),
      StoryModel(title: 'Photos', imageUrl: randomNature),
      StoryModel(title: 'From', imageUrl: randomFood),
      StoryModel(title: 'Unsplash', imageUrl: randomNature),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scaffold(
        bottomNavigationBar: _stories(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: max(20, MediaQuery.of(context).padding.top)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tornike',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        'Find me on',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: contacts.entries.map((item) {
                    return ActionChip(
                      onPressed: () => launch(item.value),
                      label: Text(item.key, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Dismiss Direction',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        style: GoogleFonts.poppins(
                          color:
                              item == direction ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 30),
              DurationSlider(
                title: 'Transition Duration',
                duration: transitionDuration,
                onChanged: (value) {
                  setState(() => transitionDuration = value);
                },
              ),
              SizedBox(height: 30),
              DurationSlider(
                title: 'Reverse Transition Duration',
                duration: reverseTransitionDuration,
                onChanged: (value) {
                  setState(() => reverseTransitionDuration = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stories() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: max(24, MediaQuery.of(context).padding.bottom),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = constraints.maxWidth;
          final itemHeight = width / 3;
          final itemWidth = width / 4;
          return SizedBox(
            height: itemHeight,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, int index) {
                final item = stories.elementAt(index);
                item.withParams(
                  transitionDuration: transitionDuration,
                  reverseTransitionDuration: reverseTransitionDuration,
                  direction: direction,
                );

                return SizedBox(
                  width: itemWidth,
                  child: StoryWidget(
                    story: item,
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
    );
  }
}

class DurationSlider extends StatelessWidget {
  final String title;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  DurationSlider({
    required this.title,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '$title - ',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${duration.inMilliseconds}ms',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
        Slider(
          value: duration.inMilliseconds.toDouble(),
          min: 0,
          max: 1000,
          divisions: 20,
          label: duration.inMilliseconds.toString(),
          onChanged: (value) {
            onChanged.call(Duration(milliseconds: value.round()));
          },
        ),
      ],
    );
  }
}
