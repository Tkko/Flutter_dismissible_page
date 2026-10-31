import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DismissiblePage E2E Integration Tests', () {
    testWidgets('Full flow: navigate, drag list at top to dismiss, route pops',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.pushTransparentRoute(
                        Scaffold(
                          body: DismissiblePage(
                            onDismissed: () => Navigator.of(context).pop(),
                            child: ListView.builder(
                              itemCount: 40,
                              itemBuilder: (ctx, i) => ListTile(
                                title: Text('List Item $i'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Page'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // 1. Open the page
      await tester.tap(find.text('Open Page'));
      await tester.pumpAndSettle();

      expect(find.text('List Item 0'), findsOneWidget);

      // 2. Drag down by 300px to trigger dismiss threshold
      await tester.drag(find.text('List Item 0'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // 3. Verify route was popped and we are back to main screen
      expect(find.text('List Item 0'), findsNothing);
      expect(find.text('Open Page'), findsOneWidget);
    });

    testWidgets(
        'Full flow: mid-scroll cannot dismiss, but top scrolls back and dismisses',
        (tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.pushTransparentRoute(
                        Scaffold(
                          body: DismissiblePage(
                            onDismissed: () => Navigator.of(context).pop(),
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: 60,
                              itemBuilder: (ctx, i) => ListTile(
                                title: Text('Scroll Item $i'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Scroll Page'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Scroll Page'));
      await tester.pumpAndSettle();

      // 1. Scroll list down (finger drags UP) by 400px
      await tester.drag(find.text('Scroll Item 0'), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(200));

      // 2. Dragging down while mid-list should scroll list up, NOT dismiss page
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pumpAndSettle();

      // Still on page
      expect(find.byType(DismissiblePage), findsOneWidget);

      // 3. Scroll all the way back to top (offset == 0)
      scrollController.jumpTo(0);
      await tester.pumpAndSettle();
      expect(scrollController.offset, 0);

      // 4. Now drag down at top: dismisses page!
      await tester.fling(
          find.text('Scroll Item 0'), const Offset(0, 450), 1000);
      await tester.pumpAndSettle();

      // Route popped
      expect(find.text('Open Scroll Page'), findsOneWidget);
      expect(find.byType(DismissiblePage), findsNothing);
    });

    testWidgets('Full flow: Slivers and CustomScrollView dismiss cleanly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.pushTransparentRoute(
                        Scaffold(
                          body: DismissiblePage(
                            onDismissed: () => Navigator.of(context).pop(),
                            child: CustomScrollView(
                              slivers: [
                                const SliverAppBar(
                                  title: Text('Sliver Header'),
                                  floating: true,
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (ctx, i) =>
                                        ListTile(title: Text('Sliver Row $i')),
                                    childCount: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Sliver Page'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sliver Page'));
      await tester.pumpAndSettle();

      expect(find.text('Sliver Header'), findsOneWidget);

      // Drag down from header
      await tester.drag(find.text('Sliver Header'), const Offset(0, 350));
      await tester.pumpAndSettle();

      // Route popped
      expect(find.text('Open Sliver Page'), findsOneWidget);
      expect(find.byType(DismissiblePage), findsNothing);
    });

    testWidgets('Full flow: PageView edge dismiss and paging', (tester) async {
      final pageController = PageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      context.pushTransparentRoute(
                        Scaffold(
                          body: DismissiblePage(
                            direction:
                                DismissiblePageDismissDirection.horizontal,
                            onDismissed: () => Navigator.of(context).pop(),
                            child: PageView(
                              controller: pageController,
                              children: const [
                                Center(child: Text('Card 0')),
                                Center(child: Text('Card 1')),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open PageView'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open PageView'));
      await tester.pumpAndSettle();

      // 1. Swipe left to next page
      await tester.fling(find.text('Card 0'), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Card 1'), findsOneWidget);

      // 2. Swipe right back to page 0
      await tester.fling(find.text('Card 1'), const Offset(500, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Card 0'), findsOneWidget);

      // 3. At page 0, drag right past start: triggers route dismiss!
      await tester.drag(find.text('Card 0'), const Offset(400, 0));
      await tester.pumpAndSettle();

      // Route popped!
      expect(find.text('Open PageView'), findsOneWidget);
      expect(find.byType(DismissiblePage), findsNothing);
    });
  });
}
