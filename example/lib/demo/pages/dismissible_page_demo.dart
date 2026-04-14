import 'dart:developer' as dev;
import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:example/demo/models/models.dart';
import 'package:example/demo/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DismissiblePageDemo extends StatefulWidget {
  const DismissiblePageDemo({super.key});

  @override
  State<DismissiblePageDemo> createState() => DismissiblePageDemoState();
}

class DismissiblePageDemoState extends State<DismissiblePageDemo> {
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
            SizedBox(height: max(20, MediaQuery.paddingOf(context).top)),
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
          context.pushTransparentRoute<void>(Properties(parent: this));
        },
        isSelected: true,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: 'Properties',
      ),
    );
  }
}

class Properties extends StatefulWidget {
  const Properties({required this.parent, super.key});

  final DismissiblePageDemoState parent;

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
      interactionMode: DismissiblePageInteractionMode.gesture,
      builder: (context, scrollController) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: GestureDetector(
            onTap: () {},
            child: Material(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Title('Bool Parameters'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppChip(
                          onSelected: () => setState(
                            () => pageModel.isFullScreen =
                                !pageModel.isFullScreen,
                          ),
                          isSelected: pageModel.isFullScreen,
                          title: 'isFullscreen',
                        ),
                        AppChip(
                          onSelected: () => setState(
                            () => pageModel.disabled = !pageModel.disabled,
                          ),
                          isSelected: pageModel.disabled,
                          title: 'disabled',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Title('Dismiss Direction'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: DismissiblePageDismissDirection.values.map((
                        item,
                      ) {
                        return AppChip(
                          onSelected: () {
                            setState(() => pageModel.direction = item);
                          },
                          isSelected: item == pageModel.direction,
                          title: '$item'.replaceAll(
                            'DismissiblePageDismissDirection.',
                            '',
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    DurationSlider(
                      title: 'Transition Duration',
                      duration: pageModel.transitionDuration,
                      onChanged: (value) {
                        setState(() => pageModel.transitionDuration = value);
                      },
                    ),
                    const SizedBox(height: 30),
                    DurationSlider(
                      title: 'Reverse Transition Duration',
                      duration: pageModel.reverseTransitionDuration,
                      onChanged: (value) {
                        setState(
                          () => pageModel.reverseTransitionDuration = value,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    DurationSlider(
                      title: 'Reverse Animation Duration',
                      duration: pageModel.reverseDuration,
                      onChanged: (value) {
                        setState(() => pageModel.reverseDuration = value);
                      },
                    ),
                    const SizedBox(height: 20),
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
    super.key,
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
                  onPressed: () => launchUrl(Uri.parse(item.value)),
                  label: Text(item.key, style: GoogleFonts.poppins()),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LargeImages extends StatelessWidget {
  const LargeImages({required this.pageModel, super.key});
  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Title('Scrollable'),
          ...images.asMap().entries.map((entry) {
            return LargeImageItem(
              imagePath: entry.value,
              pageModel: pageModel,
              scrollPhysics: entry.key.isOdd
                  ? const ClampingScrollPhysics()
                  : const BouncingScrollPhysics(),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class Stories extends StatelessWidget {
  const Stories({required this.pageModel, super.key});
  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
        bottom: max(24, MediaQuery.paddingOf(context).bottom),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemHeight = width / 3;
          final itemWidth = width / 4;
          return SizedBox(
            height: itemHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final item = pageModel.stories.elementAt(index);

                return SizedBox(
                  width: itemWidth,
                  child: StoryWidget(
                    story: item,
                    pageModel: pageModel,
                  ),
                );
              },
              separatorBuilder: (_, i) => const SizedBox(width: 10),
              itemCount: pageModel.stories.length,
            ),
          );
        },
      ),
    );
  }
}

class DismissibleDemo extends StatelessWidget {
  const DismissibleDemo({
    required this.pageModel,
    required this.builder,
    required this.interactionMode,
    super.key,
    this.startingOpacity = 1,
    this.minOpacity = .0,
    this.maxTransformValue = .5,
  });

  final DismissiblePageModel pageModel;
  final DismissiblePageBuilder builder;
  final DismissiblePageInteractionMode interactionMode;
  final double startingOpacity;
  final double minOpacity;
  final double maxTransformValue;

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        dev.log('onDismissed');
        Navigator.of(context).maybePop();
      },
      interactionMode: interactionMode,
      isFullScreen: pageModel.isFullScreen,
      minRadius: pageModel.minRadius,
      maxRadius: pageModel.maxRadius,
      dragSensitivity: pageModel.dragSensitivity,
      maxTransformValue: maxTransformValue,
      direction: pageModel.direction,
      disabled: pageModel.disabled,
      backgroundColor: pageModel.backgroundColor,
      dismissThresholds: pageModel.dismissThresholds,
      dragStartBehavior: pageModel.dragStartBehavior,
      minScale: pageModel.minScale,
      startingOpacity: startingOpacity,
      hitTestBehavior: pageModel.behavior,
      reverseDuration: pageModel.reverseDuration,
      minOpacity: minOpacity,
      // onDragStart: () => dev.log('onDragStart'),
      // onDragUpdate: (d) => dev.log('onDragUpdate: ${d.offset.dy}'),
      // onDragEnd: () => dev.log('onDragEnd'),
      builder: builder,
    );
  }
}

class Title extends StatelessWidget {
  const Title(this.text, {super.key});
  final String text;

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
  const AppChip({
    required this.onSelected,
    required this.isSelected,
    required this.title,
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.padding,
  });
  final VoidCallback onSelected;
  final bool isSelected;
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;

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
const List<String> images = [home1ImagePath, home2ImagePath];

class LargeImageItem extends StatelessWidget {
  const LargeImageItem({
    required this.imagePath,
    required this.pageModel,
    required this.scrollPhysics,
    super.key,
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
        context.pushTransparentRoute<void>(
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
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        height: 300,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              scrollPhysics is BouncingScrollPhysics
                  ? 'iOS (BouncingScrollPhysics)'
                  : 'Android (ClampingScrollPhysics)',
              style: const TextStyle(
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
    super.key,
  });

  final DismissiblePageModel pageModel;
  final ScrollPhysics scrollPhysics;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      interactionMode: DismissiblePageInteractionMode.scroll,
      startingOpacity: .6,
      maxTransformValue: 1,
      builder: (context, scrollController) => Scaffold(
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: scrollPhysics,
            child: Column(
              children: [
                Hero(
                  tag: imagePath,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                ...List.generate(40, (index) => index + 1).map((index) {
                  return SizedBox(
                    height: 50,
                    width: 300,
                    child: ListTile(
                      title: Text(
                        'Item $index',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
