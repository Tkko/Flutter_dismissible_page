import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> traceOrWatch(
  IntegrationTestWidgetsFlutterBinding binding,
  Future<void> Function() action, {
  required String reportKey,
}) async {
  if (kIsWeb) {
    // Flutter Web does not support VM timeline recording via traceAction(),
    // so we use watchPerformance() to measure client-side frame metrics.
    await binding.watchPerformance(action, reportKey: reportKey);
  } else {
    // Native targets (macOS Desktop, iOS, Android) record full VM timelines.
    await binding.traceAction(action, reportKey: reportKey);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DismissiblePage E2E Performance Benchmarks', () {
    // -------------------------------------------------------------------------
    // Scenario 1: Small Card / Dialog Widget Dismissal
    // (Benchmarks non-scrollable widgets with shadows, rounded corners, and icons)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: Small Card Widget Dismissal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.grey.shade200,
            body: Center(
              child: SizedBox(
                width: 320,
                height: 380,
                child: DismissiblePage(
                  onDismissed: () {},
                  borderRadius: const DismissiblePageRadius.transition(
                    from: 12,
                    to: 28,
                  ),
                  background: const DismissiblePageBackground.transition(
                    from: Colors.black54,
                    to: Colors.transparent,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dashboard_customize_rounded,
                          size: 56,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Modal Card Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Benchmarking drag performance with repaint isolation and single-pass matrix transformation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final center = tester.getCenter(find.text('Modal Card Title'));
          final gesture = await tester.startGesture(center);

          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(0, 4));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'small_card_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 2: SingleChildScrollView with Complex Form Layout
    // (Matches the Properties / BottomSheet modal in the example app with Wrap & Chips)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: SingleChildScrollView Properties Modal',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black87,
            body: DismissiblePage.builder(
              onDismissed: () {},
              background: DismissiblePageBackground.fadeOut(
                Colors.black,
                startOpacity: 0.5,
              ),
              builder: (context, controller) => SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Properties Settings Modal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        24,
                        (i) => Chip(
                          label: Text('Parameter Chip #$i'),
                          backgroundColor: Colors.indigo.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      10,
                      (i) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('$i')),
                          title: Text('Configuration Item #$i'),
                          subtitle: Text('Details for property setting $i'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final topText =
              tester.getCenter(find.text('Properties Settings Modal'));
          final gesture = await tester.startGesture(topText);

          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(0, 5));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'single_child_scrollview_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 3: Scrollable ListView Dismissal
    // (Matches Contacts / LargeImages list with lazy item building)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: Scrollable ListView Edge Dismissal',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage.builder(
              onDismissed: () {},
              builder: (context, controller) => ListView.builder(
                controller: controller,
                itemCount: 80,
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child:
                        Text('$i', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text('List Element #$i'),
                  subtitle: const Text('Performance test item subtitle'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final firstItem = tester.getCenter(find.text('List Element #0'));
          final gesture = await tester.startGesture(firstItem);

          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(0, 5));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'listview_edge_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 4: CustomScrollView with SliverAppBar and SliverGrid
    // (Matches the ShowcaseGallery in the example app)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: CustomScrollView with Slivers Gallery',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage.builder(
              onDismissed: () {},
              builder: (context, controller) => CustomScrollView(
                controller: controller,
                slivers: [
                  const SliverAppBar(
                    expandedHeight: 140,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Showcase Gallery'),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.primaries[index % Colors.primaries.length],
                              Colors.primaries[
                                  (index + 3) % Colors.primaries.length],
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Gallery Item #$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      childCount: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final header = tester.getCenter(find.text('Showcase Gallery'));
          final gesture = await tester.startGesture(header);

          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(0, 5));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'slivers_gallery_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 5: Horizontal PageView Stories with Vertical Dismissal
    // (Matches StoriesWrapper with CubicPageView in the example app)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: Horizontal PageView Stories Dismissal',
        (tester) async {
      final pageController = PageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: DismissiblePage(
              onDismissed: () {},
              direction: DismissiblePageDismissDirection.down,
              child: PageView.builder(
                controller: pageController,
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  color: Colors
                      .primaries[index % Colors.primaries.length].shade900,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'Story Page #$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 20,
                        right: 20,
                        child: Row(
                          children: List.generate(
                            5,
                            (barIndex) => Expanded(
                              child: Container(
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: barIndex <= index
                                      ? Colors.white
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          // 1. Swipe horizontally to test cross-axis gesture disambiguation
          await tester.fling(
            find.text('Story Page #0'),
            const Offset(-300, 0),
            1000,
          );
          await tester.pumpAndSettle();

          // 2. Drag downwards to trigger DismissiblePage vertical dismissal
          final storyText = tester.getCenter(find.text('Story Page #1'));
          final gesture = await tester.startGesture(storyText);

          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(0, 5));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'pageview_stories_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 6: Fullscreen Hero Image Viewer
    // (Matches ScrollablePage / LargeImages fullscreen image viewer)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: Fullscreen Hero Image Viewer Dismissal',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: DismissiblePage(
              onDismissed: () {},
              direction: DismissiblePageDismissDirection.all,
              background: DismissiblePageBackground.fadeOut(
                Colors.black,
                startOpacity: 0.85,
              ),
              child: Hero(
                tag: 'fullscreen_image_hero',
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.deepPurple, Colors.black],
                      radius: 0.9,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Fullscreen Viewer',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final center = tester.getCenter(find.text('Fullscreen Viewer'));
          final gesture = await tester.startGesture(center);

          // Diagonal drag (tests multi-directional DismissiblePageDismissDirection.all)
          for (var i = 0; i < 40; i++) {
            await gesture.moveBy(const Offset(3, 4));
            await tester.pump(const Duration(milliseconds: 16));
          }

          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'hero_image_viewer_dismissal',
      );
    });

    // -------------------------------------------------------------------------
    // Scenario 7: Mid-Drag Snap-back Spring Animation Performance
    // (Stress-tests frame smoothness during reverse spring-back to origin)
    // -------------------------------------------------------------------------
    testWidgets('Benchmark: Mid-Drag Snap-back Animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                height: 450,
                child: DismissiblePage(
                  onDismissed: () {},
                  reverseDuration: const Duration(milliseconds: 250),
                  child: Container(
                    color: Colors.blueAccent,
                    child: const Center(
                      child: Text(
                        'Snap-back Test',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await traceOrWatch(
        binding,
        () async {
          final center = tester.getCenter(find.text('Snap-back Test'));
          final gesture = await tester.startGesture(center);

          // Drag below dismiss threshold (e.g., 20px)
          for (var i = 0; i < 15; i++) {
            await gesture.moveBy(const Offset(0, 2));
            await tester.pump(const Duration(milliseconds: 16));
          }

          // Release to trigger animateToZero()
          await gesture.up();
          await tester.pumpAndSettle();
        },
        reportKey: 'snap_back_animation',
      );
    });
  });
}
