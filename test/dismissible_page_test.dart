import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DismissiblePage Basic & Widget Tests', () {
    testWidgets('renders child properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            onDismissed: () {},
            child: const Text('Hello Page'),
          ),
        ),
      );

      expect(find.text('Hello Page'), findsOneWidget);
    });

    testWidgets('displays static ColoredBox when disabled (enabled: false)',
        (tester) async {
      const backgroundColor = Colors.greenAccent;
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            onDismissed: () {},
            background: const DismissiblePageBackground.solid(backgroundColor),
            enabled: false,
            child: const FlutterLogo(),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == backgroundColor,
        ),
        findsOneWidget,
      );
    });

    testWidgets('omits ColoredBox when background is none', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            onDismissed: () {},
            background: const DismissiblePageBackground.none(),
            enabled: false,
            child: const FlutterLogo(),
          ),
        ),
      );

      final coloredBoxInsideDismissible = find.descendant(
        of: find.byType(DismissiblePage),
        matching: find.byType(ColoredBox),
      );
      expect(coloredBoxInsideDismissible, findsNothing);
    });

    testWidgets('onDragUpdate is called during dragging', (tester) async {
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Drag Target'),
              ),
            ),
          ),
        ),
      );

      expect(lastDetails, isNull);

      await tester.drag(find.text('Drag Target'), const Offset(0, 100));
      await tester.pump();

      expect(lastDetails, isNotNull);
      expect(lastDetails!.progress, greaterThan(0));
      expect(lastDetails!.offset.dy, greaterThan(0));
    });

    testWidgets('calls onDragStart, onDragEnd, onDismissed on fling',
        (tester) async {
      var started = false;
      var ended = false;
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () => dismissed = true,
              onDragStart: () => started = true,
              onDragEnd: () => ended = true,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Fling Target'),
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.text('Fling Target'), const Offset(0, 200), 1000);
      await tester.pump();

      expect(started, isTrue);
      expect(ended, isTrue);
      expect(dismissed, isTrue);
    });
  });

  group('DismissiblePage Scroll & Physics Integration', () {
    testWidgets(
        'ListView dragging down at top triggers page dismiss, not inner scroll',
        (tester) async {
      final controller = ScrollController();
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        ),
      );

      expect(controller.offset, 0);

      // Drag downward
      await tester.drag(find.text('Item 0'), const Offset(0, 100));
      await tester.pump();

      // Inner list MUST remain at 0.0 offset!
      expect(controller.offset, 0);
      // Page must have received the dismiss drag
      expect(lastDetails, isNotNull);
      expect(lastDetails!.offset.dy, greaterThan(0));
    });

    testWidgets(
        'Issue #36: Reversing drag mid-dismissal returns page to origin before list scrolls',
        (tester) async {
      final controller = DismissiblePageScrollController();
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              controller: controller,
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        ),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));

      // 1. Drag down 100px: triggers dismissal
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.offset, 0);
      expect(lastDetails, isNotNull);
      expect(lastDetails!.offset.dy, greaterThan(0));

      // 2. Drag up 40px (mid-drag reversal): page moves back towards origin, list must NOT scroll!
      for (var i = 0; i < 2; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.offset, 0); // Inner scroll still frozen at 0!
      expect(lastDetails!.offset.dy, greaterThan(0));

      // 3. Drag up another 100px: crosses origin, list now starts scrolling!
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0)); // Inner scroll active now!
    });

    testWidgets('CustomScrollView with slivers coordinates seamlessly',
        (tester) async {
      final controller = ScrollController();
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  const SliverAppBar(
                    title: Text('Sliver Title'),
                    expandedHeight: 100,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ListTile(title: Text('Sliver Item $i')),
                      childCount: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(controller.offset, 0);

      // Drag down at top
      await tester.drag(find.text('Sliver Title'), const Offset(0, 100));
      await tester.pump();

      expect(controller.offset, 0);
      expect(lastDetails, isNotNull);
      expect(lastDetails!.offset.dy, greaterThan(0));
    });

    testWidgets('PageView coordinates with dismissible horizontally',
        (tester) async {
      final pageController = PageController();
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              direction: DismissiblePageDismissDirection.horizontal,
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: PageView(
                controller: pageController,
                children: const [
                  Center(child: Text('Page 0')),
                  Center(child: Text('Page 1')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(pageController.page, 0);

      // Drag right at page 0 (trying to pull past start): triggers horizontal dismissal
      await tester.drag(find.text('Page 0'), const Offset(100, 0));
      await tester.pump();

      expect(pageController.page, 0);
      expect(lastDetails, isNotNull);
      expect(lastDetails!.offset.dx, greaterThan(0));
    });

    testWidgets(
        'Multi-axis scrollable allows dismissal in both directions at top/bottom',
        (tester) async {
      final controller = ScrollController();
      DismissiblePageDragUpdateDetails? lastDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              direction: DismissiblePageDismissDirection.all,
              onDismissed: () {},
              onDragUpdate: (details) => lastDetails = details,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        ),
      );

      // Drag downward at top -> dismisses
      await tester.drag(find.text('Item 0'), const Offset(0, 100));
      await tester.pump();
      expect(controller.offset, 0);
      expect(lastDetails!.offset.dy, greaterThan(0));
    });

    testWidgets('didUpdateWidget reconfigures arbiter without breaking state',
        (tester) async {
      var sensitivity = 0.5;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: DismissiblePage(
                  dragSensitivity: sensitivity,
                  onDismissed: () {},
                  child: ElevatedButton(
                    onPressed: () => setState(() => sensitivity = 1.0),
                    child: const Text('Update'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('didUpdateWidget uses updated callbacks', (tester) async {
      var useLatestCallback = false;
      var oldCallbackCalled = false;
      var newCallbackCalled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: DismissiblePage(
                  onDismissed: () {
                    if (useLatestCallback) {
                      newCallbackCalled = true;
                    } else {
                      oldCallbackCalled = true;
                    }
                  },
                  child: ElevatedButton(
                    onPressed: () => setState(() => useLatestCallback = true),
                    child: const Text('Update callback'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Update callback'));
      await tester.pump();
      await tester.fling(
        find.text('Update callback'),
        const Offset(0, 200),
        1000,
      );
      await tester.pump();

      expect(oldCallbackCalled, isFalse);
      expect(newCallbackCalled, isTrue);
    });

    testWidgets('a fast reverse fling does not dismiss the page',
        (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () => dismissed = true,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, -5));
      await gesture.up();
      await tester.pump();

      expect(dismissed, isFalse);
    });

    testWidgets('horizontal start-to-end fling uses horizontal velocity',
        (tester) async {
      var dismissed = false;
      var dragEnded = false;
      DismissiblePageDragUpdateDetails? details;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              direction: DismissiblePageDismissDirection.startToEnd,
              onDismissed: () => dismissed = true,
              onDragUpdate: (value) => details = value,
              onDragEnd: () => dragEnded = true,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(DismissiblePage),
        const Offset(60, 0),
        2000,
      );
      await tester.pump();

      expect(details, isNotNull, reason: 'drag did not reach DismissiblePage');
      expect(dragEnded, isTrue, reason: 'drag did not end');
      expect(details!.offset.dx, greaterThan(0));
      expect(dismissed, isTrue, reason: 'horizontal fling did not dismiss');
    });

    testWidgets('scroll-controller edge fling preserves gesture velocity',
        (tester) async {
      final controller = DismissiblePageScrollController();
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              controller: controller,
              onDismissed: () => dismissed = true,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (context, index) => Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.text('Item 0'), const Offset(0, 51), 1000);
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets(
        'Rebound completes at 0.0 without jumping back to release offset',
        (tester) async {
      final values = <double>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissiblePage(
              onDismissed: () {},
              onDragUpdate: (details) => values.add(details.offset.dy),
              child: ListView.builder(
                itemCount: 40,
                itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
              ),
            ),
          ),
        ),
      );

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(values.last, 0.0);
    });
  });

  group('DismissiblePageBackground Tests', () {
    test('transition resolves correctly at progress bounds and middle', () {
      const bg = DismissiblePageBackground.transition(
        from: Colors.black,
        to: Colors.transparent,
      );

      expect(bg.resolveColor(0), Colors.black);
      expect(bg.resolveColor(1), Colors.transparent);
      final mid = bg.resolveColor(0.5);
      expect(mid, isNotNull);
      expect(mid!.a, closeTo(0.5, 0.01));
    });

    test('fadeOut preserves color channels and changes opacity', () {
      final bg = DismissiblePageBackground.fadeOut(
        Colors.blue,
        startOpacity: 0.8,
        endOpacity: 0.2,
      );

      final start = bg.resolveColor(0);
      final end = bg.resolveColor(1);
      expect(start!.a, closeTo(0.8, 0.01));
      expect(end!.a, closeTo(0.2, 0.01));
    });

    test('solid returns constant color regardless of progress', () {
      const bg = DismissiblePageBackground.solid(Colors.red);
      expect(bg.resolveColor(0), Colors.red);
      expect(bg.resolveColor(0.5), Colors.red);
      expect(bg.resolveColor(1), Colors.red);
    });

    test('none returns null', () {
      const bg = DismissiblePageBackground.none();
      expect(bg.resolveColor(0), isNull);
      expect(bg.resolveColor(1), isNull);
    });

    test('equality and hashCode work properly', () {
      const bg1 = DismissiblePageBackground.solid(Colors.green);
      const bg2 = DismissiblePageBackground.solid(Colors.green);
      const bg3 = DismissiblePageBackground.none();

      expect(bg1, equals(bg2));
      expect(bg1.hashCode, equals(bg2.hashCode));
      expect(bg1, isNot(equals(bg3)));
    });
  });

  group('DismissiblePageRadius Tests', () {
    test('transition resolves radius correctly', () {
      const radius = DismissiblePageRadius.transition(from: 10, to: 50);
      expect(radius.resolveRadius(0), 10.0);
      expect(radius.resolveRadius(0.5), 30.0);
      expect(radius.resolveRadius(1), 50.0);
    });

    test('fixed returns constant radius', () {
      const radius = DismissiblePageRadius.fixed(15);
      expect(radius.resolveRadius(0), 15.0);
      expect(radius.resolveRadius(0.7), 15.0);
      expect(radius.resolveRadius(1), 15.0);
    });

    test('none returns 0', () {
      const radius = DismissiblePageRadius.none();
      expect(radius.resolveRadius(0), 0.0);
      expect(radius.resolveRadius(1), 0.0);
    });

    test('equality and hashCode work properly', () {
      const r1 = DismissiblePageRadius.fixed(12);
      const r2 = DismissiblePageRadius.fixed(12);
      const r3 = DismissiblePageRadius.transition(from: 0, to: 12);

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1, isNot(equals(r3)));
    });
  });
}
