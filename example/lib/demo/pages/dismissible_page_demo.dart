import 'dart:math';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/models/demo_settings.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/motion_lab.dart';
import 'package:dismissible_page_example/demo/scenarios/real_world.dart';
import 'package:dismissible_page_example/demo/pages/showcase_gallery.dart';
import 'package:dismissible_page_example/demo/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';

class DismissiblePageDemo extends StatefulWidget {
  const DismissiblePageDemo({super.key});

  @override
  _DismissiblePageDemoState createState() => _DismissiblePageDemoState();
}

class _DismissiblePageDemoState extends State<DismissiblePageDemo> {
  DismissiblePageModel get pageModel => DemoSettings.of(context);

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
            MotionLabCard(pageModel: pageModel),
            const RealWorldScenarios(),
            ShowcaseGallery(pageModel: pageModel),
            // Clears the floating Properties button.
            const SizedBox(height: 100),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: 'Properties',
      ),
    );
  }
}

class Properties extends StatefulWidget {
  final _DismissiblePageDemoState parent;

  const Properties({required this.parent, super.key});

  @override
  State<Properties> createState() => _PropertiesState();
}

class _PropertiesState extends State<Properties> {
  DismissiblePageModel get pageModel => widget.parent.pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      background: DismissiblePageBackground.fadeOut(
        Colors.black,
        startOpacity: .5,
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: GestureDetector(
            onTap: () {},
            child: Material(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: SingleChildScrollView(
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
                            () => pageModel.enabled = !pageModel.enabled,
                          ),
                          isSelected: pageModel.enabled,
                          title: 'enabled',
                        ),
                        AppChip(
                          onSelected: () => setState(
                            () => pageModel.continueOnDismiss =
                                !pageModel.continueOnDismiss,
                          ),
                          isSelected: pageModel.continueOnDismiss,
                          title: 'continueOnDismiss',
                        ),
                        AppChip(
                          onSelected: () => setState(
                            () => pageModel.thresholdHaptics =
                                !pageModel.thresholdHaptics,
                          ),
                          isSelected: pageModel.thresholdHaptics,
                          title: 'thresholdHaptics',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Title('Rebound'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ReboundKind.values
                          .where((item) => item != ReboundKind.custom)
                          .map((item) {
                        return AppChip(
                          onSelected: () {
                            setState(() => pageModel.selectRebound(item));
                          },
                          isSelected: item == pageModel.reboundKind,
                          title: item.name,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Title('Dismiss Direction'),
                    const SizedBox(height: 10),
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
                      title: 'Reverse Animation Duration (curve only)',
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
    super.key,
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
              const Text(
                'Tornike',
                style: DemoText.titleLargeMedium,
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  'Find me on',
                  style: DemoText.bodySmall.copyWith(color: Colors.black54),
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
                  label: Text(
                    item.key,
                    style: DemoText.plain,
                  ),
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

class Stories extends StatelessWidget {
  final DismissiblePageModel pageModel;

  const Stories({required this.pageModel, super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              separatorBuilder: (_, int i) => const SizedBox(width: 10),
              itemCount: pageModel.stories.length,
            ),
          );
        },
      ),
    );
  }
}

/// A [DismissiblePage] configured from the shared demo settings, so the
/// Properties sheet and the Motion Lab apply to every screen that uses it.
///
/// A screen overrides only what is intrinsic to it: a bottom sheet leaves
/// downwards and a chat swipes back, whatever the direction chip says.
class DismissibleDemo extends StatelessWidget {
  /// Defaults to the demo-wide settings from [DemoSettings].
  final DismissiblePageModel? pageModel;
  final Widget child;
  final DismissiblePageBackground? background;
  final DismissiblePageDismissDirection? direction;
  final DismissiblePageRadius? borderRadius;
  final double? minScale;
  final ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate;

  /// Whether a Hero flight is this screen's exit. The page then stays where it
  /// was released instead of also sliding away.
  final bool exitsThroughHero;

  const DismissibleDemo({
    super.key,
    this.pageModel,
    required this.child,
    this.background,
    this.direction,
    this.borderRadius,
    this.minScale,
    this.onDragUpdate,
    this.exitsThroughHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final model = pageModel ?? DemoSettings.of(context);
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      onDragUpdate: onDragUpdate,
      isFullScreen: model.isFullScreen,
      borderRadius: borderRadius ?? model.borderRadius,
      transform: model.transformWith(minScale: minScale),
      direction: direction ?? model.direction,
      enabled: model.enabled,
      background: background ?? model.background,
      gesture: model.gesture,
      dragStartBehavior: model.dragStartBehavior,
      hitTestBehavior: model.behavior,
      motion: exitsThroughHero
          ? model.motionWith(continueOnDismiss: false)
          : model.motion,
      child: child,
    );
  }
}

class Title extends StatelessWidget {
  final String text;

  const Title(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DemoText.subheadingMedium,
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

  const AppChip({
    super.key,
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
          style: DemoText.plain.copyWith(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
