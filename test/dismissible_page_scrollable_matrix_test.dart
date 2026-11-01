import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Build = Widget Function(
  ScrollController? controller,
  Axis axis, {
  required bool reverse,
});

Widget _items(Axis axis) => SizedBox(
      width: axis == Axis.horizontal ? 80 : null,
      height: axis == Axis.vertical ? 80 : null,
      child: const Text('x'),
    );

final Map<String, _Build> _scrollables = {
  'ListView': (c, axis, {required reverse}) => ListView.builder(
        controller: c,
        scrollDirection: axis,
        reverse: reverse,
        itemCount: 60,
        itemBuilder: (_, __) => _items(axis),
      ),
  'GridView': (c, axis, {required reverse}) => GridView.builder(
        controller: c,
        scrollDirection: axis,
        reverse: reverse,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 120,
        itemBuilder: (_, __) => const Text('x'),
      ),
  'CustomScrollView': (c, axis, {required reverse}) => CustomScrollView(
        controller: c,
        scrollDirection: axis,
        reverse: reverse,
        slivers: [
          SliverList.builder(
            itemCount: 60,
            itemBuilder: (_, __) => _items(axis),
          ),
        ],
      ),
  'SingleChildScrollView': (c, axis, {required reverse}) =>
      SingleChildScrollView(
        controller: c,
        scrollDirection: axis,
        reverse: reverse,
        child: axis == Axis.vertical
            ? const SizedBox(width: 400, height: 4000)
            : const SizedBox(width: 4000, height: 600),
      ),
};

void main() {
  for (final physics in <String, ScrollPhysics>{
    'clamping': const ClampingScrollPhysics(),
    'bouncing': const BouncingScrollPhysics(),
  }.entries) {
    for (final entry in _scrollables.entries) {
      for (final withController in [true, false]) {
        for (final reverse in [false, true]) {
          final name = '${entry.key} ${physics.key} '
              '${withController ? 'controller' : 'plain'}'
              '${reverse ? ' reversed' : ''}';

          testWidgets('vertical: $name', (tester) async {
            final controller =
                withController ? DismissiblePageScrollController() : null;
            // A scrollable with its own controller bypasses the page's
            // controller and exercises the notification fallback.
            final scrollController = controller ?? ScrollController();
            addTearDown(scrollController.dispose);
            var dy = 0.0;
            var dismissed = false;

            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: DismissiblePage(
                    controller: controller,
                    onDismissed: () => dismissed = true,
                    onDragUpdate: (d) => dy = d.offset.dy,
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior()
                          .copyWith(physics: physics.value),
                      child: entry.value(
                        scrollController,
                        Axis.vertical,
                        reverse: reverse,
                      ),
                    ),
                  ),
                ),
              ),
            );

            // Lists start at the top (drag down overscrolls); reversed lists
            // start at the bottom (drag up overscrolls).
            final edgeSign = reverse ? -1.0 : 1.0;

            // Edge drag moves the page in the dragged direction.
            final g = await tester.startGesture(const Offset(200, 300));
            for (var i = 0; i < 8; i++) {
              await g.moveBy(Offset(0, edgeSign * 10));
              await tester.pump(const Duration(milliseconds: 16));
            }
            expect(
              dy * edgeSign,
              greaterThan(0),
              reason: 'page should follow the overscroll drag',
            );
            await g.up();
            await tester.pumpAndSettle();
            expect(dy, 0, reason: 'page rebounds to origin');
            expect(dismissed, isFalse);

            // Scrolling the other way scrolls content and leaves page alone.
            final scroll = await tester.startGesture(const Offset(200, 300));
            for (var i = 0; i < 8; i++) {
              await scroll.moveBy(Offset(0, -edgeSign * 20));
              await tester.pump(const Duration(milliseconds: 16));
            }
            await scroll.up();
            await tester.pumpAndSettle();
            expect(dy, 0);
            expect(dismissed, isFalse);

            // A fling from the edge dismisses.
            final back = await tester.startGesture(const Offset(200, 300));
            // return to the edge first
            for (var i = 0; i < 30; i++) {
              await back.moveBy(Offset(0, edgeSign * 40));
              await tester.pump(const Duration(milliseconds: 16));
            }
            await back.up();
            await tester.pumpAndSettle();
            expect(dismissed, isTrue, reason: 'dragging far enough dismisses');
          });
        }
      }
    }
  }

  for (final rtl in [false, true]) {
    for (final withController in [true, false]) {
      testWidgets(
          'horizontal ListView ${withController ? 'controller' : 'plain'}'
          '${rtl ? ' rtl' : ''}: edge drag toward end dismisses',
          (tester) async {
        final controller =
            withController ? DismissiblePageScrollController() : null;
        final scrollController = controller ?? ScrollController();
        addTearDown(scrollController.dispose);
        var dx = 0.0;
        var dismissed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                body: DismissiblePage(
                  controller: controller,
                  direction: DismissiblePageDismissDirection.horizontal,
                  onDismissed: () => dismissed = true,
                  onDragUpdate: (d) => dx = d.offset.dx,
                  child: ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 40,
                    itemBuilder: (_, __) => _items(Axis.horizontal),
                  ),
                ),
              ),
            ),
          ),
        );

        // LTR lists start at the left edge: dragging right overscrolls.
        // RTL lists start at the right edge: dragging left overscrolls.
        final sign = rtl ? -1.0 : 1.0;
        final g = await tester.startGesture(const Offset(200, 300));
        for (var i = 0; i < 8; i++) {
          await g.moveBy(Offset(sign * 10, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(dx * sign, greaterThan(0));
        await g.up();
        await tester.pumpAndSettle();
        expect(dx, 0);

        await tester.fling(
          find.byType(ListView),
          Offset(sign * 120, 0),
          2500,
        );
        await tester.pumpAndSettle();
        expect(dismissed, isTrue);
      });
    }
  }

  testWidgets('mouse wheel scrolling never moves the page', (tester) async {
    var dy = 0.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DismissiblePage(
            onDismissed: () {},
            onDragUpdate: (d) => dy = d.offset.dy,
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (_, i) => SizedBox(height: 60, child: Text('$i')),
            ),
          ),
        ),
      ),
    );
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(const Offset(200, 300)));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, -300)));
    await tester.pump();
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 300)));
    await tester.pumpAndSettle();
    expect(dy, 0);
  });
}
