import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/expanding_hero.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _cardRadius = 26.0;
const _background = Color(0xfff2f2f7);

/// A feed of story cards like the App Store's Today tab. A card expands in
/// place into its story: the card visual grows into the page header, and
/// dragging the page away shrinks it back into the card.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  static const _weekdays = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY',
    'SUNDAY', //
  ];
  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST',
    'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER', //
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} '
                    '${now.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => DismissiblePage.dismiss(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(
              'Today',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            for (final story in demoStories)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _StoryCard(story: story),
              ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatefulWidget {
  const _StoryCard({required this.story});

  final DemoStory story;

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final width = MediaQuery.sizeOf(context).width - 40;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        setState(() => _pressed = false);
        context.pushTransparentRoute(
          StoryPage(story: story),
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 380),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: width * 1.2,
            child: ExpandingHero(
              tag: story.tag,
              radius: _cardRadius,
              child: StoryVisual(story: story),
            ),
          ),
        ),
      ),
    );
  }
}

/// The picture and headline shared by a card and its page header. It fills
/// whatever size it is given, with the text anchored to the bottom, so it
/// can grow from one into the other without relayout jumps.
class StoryVisual extends StatelessWidget {
  const StoryVisual({required this.story, super.key});

  final DemoStory story;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DemoImage(story.photo.url),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 1],
              colors: [Color(0x00000000), Color(0xcc000000)],
            ),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.category,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                story.title,
                maxLines: 3,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                story.subtitle,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StoryPage extends StatefulWidget {
  const StoryPage({required this.story, super.key});

  final DemoStory story;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final _progress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final width = MediaQuery.sizeOf(context).width;

    return DismissibleDemo(
      onDragUpdate: (details) => _progress.value = details.progress,
      // The Hero flight is the exit, so the page must not slide away too.
      exitsThroughHero: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: width * 1.2,
                  child: ExpandingHero(
                    tag: story.tag,
                    child: StoryVisual(story: story),
                  ),
                ),
                _Reveal(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Paragraph(story.paragraphs.first),
                        const _FeaturedApp(),
                        for (final text in story.paragraphs.skip(1))
                          _Paragraph(text),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _progress,
                    builder: (context, progress, child) => Opacity(
                      opacity: (1 - progress * 3).clamp(0.0, 1.0),
                      child: child,
                    ),
                    child: Material(
                      color: Colors.black45,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and lifts the story body in once the header has mostly grown, and
/// back out first on the way down.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final reveal = route.drive(
      CurveTween(curve: const Interval(0.45, 1, curve: Curves.easeOutCubic)),
    );
    return FadeTransition(
      opacity: reveal,
      child: SlideTransition(
        position: reveal.drive(
          Tween(begin: const Offset(0, 0.05), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15.5,
          height: 1.7,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// The ad slot of a Today story: an app tile with a Get button.
class _FeaturedApp extends StatelessWidget {
  const _FeaturedApp();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffffb347), Color(0xffff5c8a)],
              ),
            ),
            child: const Icon(Icons.wb_twilight_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Golden Hour',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Plan your light',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff0a84ff),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {},
            child: Text(
              'GET',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
