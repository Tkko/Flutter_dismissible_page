import 'dart:math';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/demo/models/models.dart';
import 'package:example/demo/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DismissiblePageDemo extends StatefulWidget {
  const DismissiblePageDemo({Key? key}) : super(key: key);

  @override
  _DismissiblePageDemoState createState() => _DismissiblePageDemoState();
}

class _DismissiblePageDemoState extends State<DismissiblePageDemo> {
  DismissiblePageModel pageModel = DismissiblePageModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _propertiesButton(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: max(20, MediaQuery.of(context).padding.top)),
            Contacts(pageModel: pageModel),
            Stories(pageModel: pageModel),
            LargeImages(pageModel: pageModel),
          ],
        ),
      ),
    );
  }

  Widget _propertiesButton() {
    return Hero(
      tag: 'TT',
      child: AppChip(
        onSelected: () {
          context.pushTransparentRoute(Properties(parent: this));
        },
        isSelected: true,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: 'Properties',
      ),
    );
  }
}

class Properties extends StatefulWidget {
  final _DismissiblePageDemoState parent;

  const Properties({required this.parent, Key? key}) : super(key: key);

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  DismissiblePageModel get pageModel => widget.parent.pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      startingOpacity: .5,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: GestureDetector(
            onTap: () {},
            child: Material(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Title('Bool Parameters'),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      AppChip(
                        onSelected: () => setState(() =>
                            pageModel.isFullScreen = !pageModel.isFullScreen),
                        isSelected: pageModel.isFullScreen,
                        title: 'isFullscreen',
                      ),
                      AppChip(
                        onSelected: () => setState(
                            () => pageModel.disabled = !pageModel.disabled),
                        isSelected: pageModel.disabled,
                        title: 'disabled',
                      ),
                    ]),
                    SizedBox(height: 20),
                    Title('Dismiss Direction'),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          DismissiblePageDismissDirection.values.map((item) {
                        return AppChip(
                          onSelected: () {
                            setState(() => pageModel.direction = item);
                          },
                          isSelected: item == pageModel.direction,
                          title: '$item'.replaceAll(
                              'DismissiblePageDismissDirection.', ''),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    DurationSlider(
                      title: 'Transition Duration',
                      duration: pageModel.transitionDuration,
                      onChanged: (value) {
                        setState(() => pageModel.transitionDuration = value);
                      },
                    ),
                    SizedBox(height: 30),
                    DurationSlider(
                      title: 'Reverse Transition Duration',
                      duration: pageModel.reverseTransitionDuration,
                      onChanged: (value) {
                        setState(
                            () => pageModel.reverseTransitionDuration = value);
                      },
                    ),
                    SizedBox(height: 30),
                    DurationSlider(
                      title: 'Reverse Animation Duration',
                      duration: pageModel.reverseDuration,
                      onChanged: (value) {
                        setState(() => pageModel.reverseDuration = value);
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Contacts extends StatelessWidget {
  const Contacts({
    required this.pageModel,
  });

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pageModel.contacts.entries.map((item) {
                return ActionChip(
                  onPressed: () => launch(item.value),
                  label: Text(item.key, style: GoogleFonts.poppins()),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LargeImages extends StatelessWidget {
  final DismissiblePageModel pageModel;

  const LargeImages({Key? key, required this.pageModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Title('Scrollable'),
          ...images.asMap().entries.map((entry) {
            return LargeImageItem(
              imagePath: entry.value,
              pageModel: pageModel,
              scrollPhysics: entry.key.isOdd
                  ? ClampingScrollPhysics()
                  : BouncingScrollPhysics(),
            );
          }),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class Stories extends StatelessWidget {
  final DismissiblePageModel pageModel;

  const Stories({required this.pageModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
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
                final item = pageModel.stories.elementAt(index);

                return SizedBox(
                  width: itemWidth,
                  child: StoryWidget(
                    story: item,
                    pageModel: pageModel,
                  ),
                );
              },
              separatorBuilder: (_, int i) => SizedBox(width: 10),
              itemCount: pageModel.stories.length,
            ),
          );
        },
      ),
    );
  }
}

class DismissibleDemo extends StatelessWidget {
  final DismissiblePageModel pageModel;
  final Widget child;
  final double startingOpacity;

  const DismissibleDemo({
    Key? key,
    required this.pageModel,
    required this.child,
    this.startingOpacity = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      isFullScreen: pageModel.isFullScreen,
      minRadius: pageModel.minRadius,
      maxRadius: pageModel.maxRadius,
      dragSensitivity: pageModel.dragSensitivity,
      maxTransformValue: pageModel.maxTransformValue,
      direction: pageModel.direction,
      disabled: pageModel.disabled,
      backgroundColor: pageModel.backgroundColor,
      dismissThresholds: pageModel.dismissThresholds,
      dragStartBehavior: pageModel.dragStartBehavior,
      minScale: pageModel.minScale,
      startingOpacity: startingOpacity,
      behavior: pageModel.behavior,
      reverseDuration: pageModel.reverseDuration,
      // onDragUpdate: (d) => print(d.offset.dy),
      child: child,
    );
  }
}

class Title extends StatelessWidget {
  final String text;

  Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  final VoidCallback onSelected;
  final bool isSelected;
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;

  AppChip({
    required this.onSelected,
    required this.isSelected,
    required this.title,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ChoiceChip(
        onSelected: (_) => onSelected(),
        selected: isSelected,
        padding: padding,
        label: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

const home1ImagePath = 'assets/images/home_1.png';
const home2ImagePath = 'assets/images/home_2.png';
const images = [home1ImagePath, home2ImagePath];

class LargeImageItem extends StatelessWidget {
  LargeImageItem({
    required this.imagePath,
    required this.pageModel,
    required this.scrollPhysics,
  });

  final DismissiblePageModel pageModel;
  final String imagePath;
  final ScrollPhysics scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use extension method to use [TransparentRoute]
        // This will push page without route background
        context.pushTransparentRoute(
          LargeImageDetailsPage(
            imagePath: imagePath,
            pageModel: pageModel,
            scrollPhysics: scrollPhysics,
          ),
        );
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: imagePath,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              scrollPhysics is BouncingScrollPhysics
                  ? 'iOS (BouncingScrollPhysics)'
                  : 'Android (ClampingScrollPhysics)',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LargeImageDetailsPage extends StatelessWidget {
  const LargeImageDetailsPage({
    required this.imagePath,
    required this.pageModel,
    required this.scrollPhysics,
  });

  final DismissiblePageModel pageModel;
  final ScrollPhysics scrollPhysics;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      // direction: DismissiblePageDismissDirection.multi,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: scrollPhysics,
          child: Column(
            children: [
              Hero(
                tag: imagePath,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              ...List.generate(25, (index) => index + 1).map((index) {
                return ListTile(
                  title: Text(
                    'Item $index',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
