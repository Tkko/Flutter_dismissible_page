import 'dart:async';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _start = Offset(200, 300);
const _dragSensitivity = 0.7;

/// How the scrollable relates to the page. Only [pageController] moves the
/// page from the scroll position; the others go through scroll notifications.
enum _Wiring { pageController, scrollableOnlyController, plainController }

class _Rig {
  _Rig(this.tester, this.controller);

  final WidgetTester tester;
  final ScrollController controller;

  double dy = 0;
  double minDy = 0;
  double maxDy = 0;
  bool dismissed = false;

  /// The scroll offset seen out of range while the page was displaced.
  double? overscrollUnderPage;

  double get offset => controller.offset;

  void onDragUpdate(DismissiblePageDragUpdateDetails details) {
    dy = details.offset.dy;
    if (dy < minDy) minDy = dy;
    if (dy > maxDy) maxDy = dy;
    if (dy != 0 && controller.position.outOfRange) {
      overscrollUnderPage = controller.offset;
    }
  }

  Future<void> drag(
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
}

Future<_Rig> _pump(
  WidgetTester tester,
  ScrollPhysics physics, {
  _Wiring wiring = _Wiring.pageController,
  bool reverse = false,
  FutureOr<bool> Function()? onWillDismiss,
  VoidCallback? onDragStart,
  VoidCallback? onDragEnd,
}) async {
  final controller = wiring == _Wiring.plainController
      ? ScrollController()
      : DismissiblePageScrollController();
  addTearDown(controller.dispose);
  final rig = _Rig(tester, controller);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DismissiblePage(
          controller: wiring == _Wiring.pageController
              ? controller as DismissiblePageScrollController
              : null,
          transform:
              const DismissiblePageTransform(dragSensitivity: _dragSensitivity),
          onDismissed: () => rig.dismissed = true,
          onDragUpdate: rig.onDragUpdate,
          onWillDismiss: onWillDismiss,
          onDragStart: onDragStart,
          onDragEnd: onDragEnd,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(physics: physics),
            child: SingleChildScrollView(
              controller: controller,
              reverse: reverse,
              child: const SizedBox(width: 400, height: 4000),
            ),
          ),
        ),
      ),
    ),
  );
  return rig;
}

/// Scrolls away from the top and back past it, in one gesture that began at
/// the top. The last move crosses the edge, which is where bouncing physics
/// would overshoot.
Future<TestGesture> _overshootTop(_Rig rig) async {
  final gesture = await rig.tester.startGesture(_start);
  await rig.drag(gesture, -105);
  await rig.drag(gesture, 113, step: 13);
  return gesture;
}

/// Flings a bouncing list into its top edge and returns while it overscrolls.
Future<void> _bounceOffTop(_Rig rig) async {
  final tester = rig.tester;
  final scroll = await tester.startGesture(_start);
  await rig.drag(scroll, -400, step: 20);
  await scroll.up();
  await tester.pumpAndSettle();

  await tester.fling(
    find.byType(SingleChildScrollView),
    const Offset(0, 300),
    3000,
  );
  for (var i = 0; i < 40 && rig.offset >= -5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(rig.offset, lessThan(-5), reason: 'the list must be mid-bounce');
}

void main() {
  for (final physics in <String, ScrollPhysics>{
    'clamping': const ClampingScrollPhysics(),
    'bouncing': const BouncingScrollPhysics(),
  }.entries) {
    group('${physics.key} physics with the page controller', () {
      testWidgets('pulling the page and pushing back scrolls the content',
          (tester) async {
        final rig = await _pump(tester, physics.value);

        final gesture = await tester.startGesture(_start);
        await rig.drag(gesture, 100);
        expect(rig.dy, greaterThan(0));
        await rig.drag(gesture, -300);
        await gesture.up();
        await tester.pumpAndSettle();

        expect(rig.dy, 0);
        expect(rig.minDy, 0, reason: 'the page must stop at its origin');
        expect(rig.offset, greaterThan(100));
        expect(rig.overscrollUnderPage, isNull);
        expect(rig.dismissed, isFalse);
      });

      testWidgets('a fast reversal hands the rest to the list', (tester) async {
        final rig = await _pump(tester, physics.value);

        final gesture = await tester.startGesture(_start);
        await rig.drag(gesture, 80, step: 40);
        await rig.drag(gesture, -400, step: 100);
        await gesture.up();
        await tester.pumpAndSettle();

        expect(rig.dy, 0);
        expect(rig.minDy, 0);
        expect(rig.offset, greaterThan(100));
        expect(rig.dismissed, isFalse);
      });

      testWidgets('pushing up after crossing the top does not lift the page',
          (tester) async {
        final rig = await _pump(tester, physics.value);

        final gesture = await _overshootTop(rig);
        expect(rig.offset, 0, reason: 'the list stops at the edge');
        expect(rig.dy, greaterThan(0));

        await rig.drag(gesture, -300, step: 3);
        await gesture.up();
        await tester.pumpAndSettle();

        expect(rig.dy, 0);
        expect(rig.minDy, 0, reason: 'the page must stop at its origin');
        expect(rig.offset, greaterThan(100));
        expect(rig.overscrollUnderPage, isNull);
        expect(rig.dismissed, isFalse);
      });

      testWidgets('pushing down after crossing the bottom keeps the page',
          (tester) async {
        final rig = await _pump(tester, physics.value);
        final max = rig.controller.position.maxScrollExtent;
        rig.controller.jumpTo(max);
        await tester.pump();

        final gesture = await tester.startGesture(_start);
        await rig.drag(gesture, 105);
        await rig.drag(gesture, -113, step: 13);
        expect(rig.offset, max, reason: 'the list stops at the edge');
        expect(rig.dy, lessThan(0));

        await rig.drag(gesture, 300, step: 3);
        await gesture.up();
        await tester.pumpAndSettle();

        expect(rig.dy, 0);
        expect(rig.maxDy, 0, reason: 'the page must stop at its origin');
        expect(rig.offset, lessThan(max - 100));
        expect(rig.overscrollUnderPage, isNull);
        expect(rig.dismissed, isFalse);
      });

      testWidgets('a delta crossing the edge moves the page once',
          (tester) async {
        final rig = await _pump(tester, physics.value);

        final gesture = await tester.startGesture(_start);
        await rig.drag(gesture, -100);
        final toTop = rig.offset;
        expect(toTop, greaterThan(0));

        await rig.drag(gesture, toTop + 30, step: toTop + 30);
        expect(rig.offset, 0);
        expect(rig.dy, closeTo(30 * _dragSensitivity, 0.001));
        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('carrying on past the top still dismisses', (tester) async {
        final rig = await _pump(tester, physics.value);

        final gesture = await _overshootTop(rig);
        await rig.drag(gesture, 400);
        await gesture.up();
        await tester.pumpAndSettle();

        expect(rig.overscrollUnderPage, isNull);
        expect(rig.dismissed, isTrue);
      });
    });

    for (final wiring in [
      _Wiring.scrollableOnlyController,
      _Wiring.plainController,
    ]) {
      group('${physics.key} physics with ${wiring.name}', () {
        testWidgets('a pull still dismisses', (tester) async {
          final rig = await _pump(tester, physics.value, wiring: wiring);

          final gesture = await tester.startGesture(_start);
          await rig.drag(gesture, 600, step: 20);
          await gesture.up();
          await tester.pumpAndSettle();

          expect(rig.dismissed, isTrue);
        });

        testWidgets('pulling and pushing back stops the page at its origin',
            (tester) async {
          final rig = await _pump(tester, physics.value, wiring: wiring);

          final gesture = await tester.startGesture(_start);
          await rig.drag(gesture, 100);
          expect(rig.dy, greaterThan(0));
          await rig.drag(gesture, -300);
          await gesture.up();
          await tester.pumpAndSettle();

          expect(rig.dy, 0);
          expect(rig.minDy, 0, reason: 'the page must stop at its origin');
          expect(rig.offset, greaterThan(100));
          expect(rig.dismissed, isFalse);
        });

        testWidgets('pushing up after crossing the top does not lift the page',
            (tester) async {
          final rig = await _pump(tester, physics.value, wiring: wiring);

          final gesture = await _overshootTop(rig);
          await rig.drag(gesture, -300, step: 3);
          await gesture.up();
          await tester.pumpAndSettle();

          expect(rig.dy, 0);
          expect(rig.minDy, 0, reason: 'the page must stop at its origin');
          expect(rig.offset, greaterThan(100));
          expect(rig.dismissed, isFalse);
        });

        testWidgets('a reversed list stops the page at its origin',
            (tester) async {
          final rig = await _pump(
            tester,
            physics.value,
            wiring: wiring,
            reverse: true,
          );

          final gesture = await tester.startGesture(_start);
          await rig.drag(gesture, -100);
          expect(rig.dy, lessThan(0));
          await rig.drag(gesture, 300);
          await gesture.up();
          await tester.pumpAndSettle();

          expect(rig.dy, 0);
          expect(rig.maxDy, 0, reason: 'the page must stop at its origin');
          expect(rig.offset, greaterThan(100));
          expect(rig.dismissed, isFalse);
        });

        testWidgets('every drag start gets a drag end', (tester) async {
          var starts = 0;
          var ends = 0;
          final rig = await _pump(
            tester,
            physics.value,
            wiring: wiring,
            onDragStart: () => starts++,
            onDragEnd: () => ends++,
          );

          final first = await tester.startGesture(_start);
          await rig.drag(first, 60);
          await first.up();
          // Mid-rebound: the page is displaced but no longer dragging.
          await tester.pump(const Duration(milliseconds: 16));
          expect(rig.dy, greaterThan(0));

          final second = await tester.startGesture(_start);
          // The first move only wins the arena; the next one crosses the
          // origin in a single update.
          await second.moveBy(const Offset(0, -20));
          await rig.drag(second, -300, step: 300);
          await tester.pump(const Duration(milliseconds: 16));
          expect(rig.dy, 0, reason: 'the rebound must not resume');
          await second.up();
          await tester.pumpAndSettle();

          expect(rig.dy, 0);
          expect(rig.minDy, 0);
          expect(starts, greaterThan(0));
          expect(ends, starts);
        });

        testWidgets('a pending confirmation holds the page', (tester) async {
          final answer = Completer<bool>();
          final rig = await _pump(
            tester,
            physics.value,
            wiring: wiring,
            onWillDismiss: () => answer.future,
          );

          final pull = await tester.startGesture(_start);
          await rig.drag(pull, 600, step: 20);
          await pull.up();
          await tester.pump(const Duration(milliseconds: 500));
          final held = rig.dy;
          expect(held, greaterThan(0));

          final push = await tester.startGesture(_start);
          // The first move only wins the arena; the next one would cross the
          // origin in a single update.
          await push.moveBy(const Offset(0, -20));
          await rig.drag(push, -1500, step: 1500);
          await push.up();
          await tester.pump(const Duration(milliseconds: 16));
          expect(rig.dy, held, reason: 'the page waits for the answer');

          answer.complete(false);
          await tester.pumpAndSettle();
          expect(rig.dy, 0);
          expect(rig.dismissed, isFalse);
        });
      });
    }
  }

  for (final wiring in [
    _Wiring.scrollableOnlyController,
    _Wiring.plainController,
  ]) {
    testWidgets('re-grabbing a bounce with ${wiring.name} keeps the page down',
        (tester) async {
      final rig = await _pump(
        tester,
        const BouncingScrollPhysics(),
        wiring: wiring,
      );
      await _bounceOffTop(rig);

      final gesture = await tester.startGesture(_start);
      await rig.drag(gesture, 60, step: 5);
      await rig.drag(gesture, -300, step: 3);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(rig.minDy, 0, reason: 'the page must not follow the finger up');
      expect(rig.offset, greaterThan(100));
      expect(rig.dismissed, isFalse);
    });
  }

  group('grabbing a bouncing list', () {
    const physics = BouncingScrollPhysics();

    testWidgets('a pull stays with the bounce and settles', (tester) async {
      final rig = await _pump(tester, physics);
      await _bounceOffTop(rig);

      final gesture = await tester.startGesture(_start);
      await rig.drag(gesture, 60, step: 5);
      expect(rig.dy, 0, reason: 'the bounce must not freeze under the page');
      await gesture.up();
      await tester.pumpAndSettle();

      expect(rig.offset, 0, reason: 'the bounce must spring back');
      expect(rig.dismissed, isFalse);
    });

    testWidgets('pull then push scrolls the content', (tester) async {
      final rig = await _pump(tester, physics);
      await _bounceOffTop(rig);

      final gesture = await tester.startGesture(_start);
      await rig.drag(gesture, 60, step: 5);
      await rig.drag(gesture, -300, step: 3);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(rig.minDy, 0, reason: 'the page must not follow the finger up');
      expect(rig.offset, greaterThan(100));
      expect(rig.dismissed, isFalse);
    });

    testWidgets('a new pull once it settled dismisses', (tester) async {
      final rig = await _pump(tester, physics);
      await _bounceOffTop(rig);
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(_start);
      await rig.drag(gesture, 600, step: 20);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(rig.dismissed, isTrue);
    });
  });
}
