import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required DismissiblePageScrollController controller,
  VoidCallback? onDismissed,
  VoidCallback? onDragStart,
  VoidCallback? onDragEnd,
  ValueChanged<DismissiblePageDragUpdateDetails>? onDragUpdate,
  bool enabled = true,
  DismissiblePageDismissDirection direction =
      DismissiblePageDismissDirection.vertical,
  double dragSensitivity = 0.7,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DismissiblePage(
        controller: controller,
        enabled: enabled,
        direction: direction,
        dragSensitivity: dragSensitivity,
        onDismissed: onDismissed ?? () {},
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        onDragUpdate: onDragUpdate,
        child: ListView.builder(
          controller: controller,
          itemCount: 50,
          itemBuilder: (context, index) => SizedBox(
            height: 56,
            child: Text('Item $index'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _dragBy(
  WidgetTester tester,
  TestGesture gesture,
  double dy, {
  double step = 10,
}) async {
  final sign = dy < 0 ? -1.0 : 1.0;
  var remaining = dy.abs();
  while (remaining > 0) {
    final d = remaining < step ? remaining : step;
    await gesture.moveBy(Offset(0, sign * d));
    await tester.pump(const Duration(milliseconds: 16));
    remaining -= d;
  }
}

void main() {
  group('Scroll controller edge cases', () {
    testWidgets(
        're-grabbing the page while it rebounds ends the drag on release',
        (tester) async {
      final controller = DismissiblePageScrollController();
      var starts = 0;
      var ends = 0;
      var dy = 0.0;

      await tester.pumpWidget(
        _app(
          controller: controller,
          onDragStart: () => starts++,
          onDragEnd: () => ends++,
          onDragUpdate: (d) => dy = d.offset.dy,
        ),
      );

      final first = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, first, 40);
      await first.up();
      // Mid-rebound.
      await tester.pump(const Duration(milliseconds: 50));
      expect(dy, greaterThan(0));

      final second = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, second, 60);
      await second.up();
      await tester.pumpAndSettle();

      expect(dy, 0, reason: 'page must settle back to origin');
      expect(ends, starts, reason: 'every drag start needs a drag end');
    });

    testWidgets('dragging back past the origin ends the page drag',
        (tester) async {
      final controller = DismissiblePageScrollController();
      var starts = 0;
      var ends = 0;

      await tester.pumpWidget(
        _app(
          controller: controller,
          onDragStart: () => starts++,
          onDragEnd: () => ends++,
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, gesture, 30);
      await _dragBy(tester, gesture, -200);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(starts, 1);
      expect(ends, 1);
      expect(controller.offset, greaterThan(0));

      // A fresh gesture at the top must start a fresh page drag.
      controller.jumpTo(0);
      await tester.pump();
      final again = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, again, 30);
      await again.up();
      await tester.pumpAndSettle();
      expect(starts, 2);
      expect(ends, 2);
    });

    testWidgets('toggling enabled keeps the scroll position', (tester) async {
      final controller = DismissiblePageScrollController();
      var enabled = true;
      late StateSetter rebuild;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _app(controller: controller, enabled: enabled);
          },
        ),
      );

      controller.jumpTo(300);
      await tester.pump();

      rebuild(() => enabled = false);
      await tester.pump();
      expect(controller.offset, 300);

      rebuild(() => enabled = true);
      await tester.pump();
      expect(controller.offset, 300);
    });

    testWidgets('changing configuration mid-drag keeps the page offset',
        (tester) async {
      final controller = DismissiblePageScrollController();
      var sensitivity = 0.7;
      late StateSetter rebuild;
      var dy = 0.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _app(
              controller: controller,
              dragSensitivity: sensitivity,
              onDragUpdate: (d) => dy = d.offset.dy,
            );
          },
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, gesture, 40);
      final before = dy;
      expect(before, greaterThan(0));

      rebuild(() => sensitivity = 1.0);
      await tester.pump();

      await _dragBy(tester, gesture, 10);
      expect(dy, greaterThan(before));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(dy, 0);
    });

    testWidgets('disabling mid-drag resets the page', (tester) async {
      final controller = DismissiblePageScrollController();
      var enabled = true;
      late StateSetter rebuild;
      var dy = 0.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _app(
              controller: controller,
              enabled: enabled,
              onDragUpdate: (d) => dy = d.offset.dy,
            );
          },
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, gesture, 40);
      expect(dy, greaterThan(0));

      rebuild(() => enabled = false);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(dy, 0);

      // Scrolling still works once disabled.
      await tester.drag(find.text('Item 3'), const Offset(0, -100));
      await tester.pump();
      expect(controller.offset, greaterThan(0));
    });

    testWidgets('removing the scrollable mid-drag does not throw',
        (tester) async {
      final controller = DismissiblePageScrollController();
      var showList = true;
      late StateSetter rebuild;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return MaterialApp(
              home: Scaffold(
                body: DismissiblePage(
                  controller: controller,
                  onDismissed: () {},
                  child: showList
                      ? ListView.builder(
                          controller: controller,
                          itemCount: 20,
                          itemBuilder: (_, i) => Text('Item $i'),
                        )
                      : const SizedBox.expand(),
                ),
              ),
            );
          },
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await _dragBy(tester, gesture, 40);
      rebuild(() => showList = false);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('page without an explicit controller disposes cleanly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            onDismissed: () {},
            child: ListView(children: const [Text('a'), Text('b')]),
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
