import 'dart:async';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget page) => MaterialApp(
      home: Center(child: SizedBox(width: 400, height: 600, child: page)),
    );

/// Drags the page by [by] from [from] and lets go slowly.
Future<void> _drag(
  WidgetTester tester,
  Offset by, {
  Offset from = const Offset(400, 300),
}) async {
  final gesture = await tester.startGesture(from);
  await gesture.moveBy(by);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  group('models', () {
    test('drag update details compare every field', () {
      const a = DismissiblePageDragUpdateDetails(radius: 1, opacity: 1);
      const sameOffsetOtherProgress = DismissiblePageDragUpdateDetails(
        radius: 1,
        opacity: 1,
        progress: 0.5,
      );
      expect(a, const DismissiblePageDragUpdateDetails(radius: 1, opacity: 1));
      expect(a, isNot(sameOffsetOtherProgress));
      expect(
        a.hashCode,
        const DismissiblePageDragUpdateDetails(radius: 1, opacity: 1).hashCode,
      );
    });

    test('rebound and exit variants are value types', () {
      expect(
        const DismissiblePageRebound.curve(),
        const DismissiblePageRebound.curve(),
      );
      expect(
        const DismissiblePageRebound.curve(),
        isNot(
          const DismissiblePageRebound.curve(
            duration: Duration(milliseconds: 400),
          ),
        ),
      );
      expect(
        const DismissiblePageRebound.bouncy(),
        const DismissiblePageRebound.spring(dampingRatio: 0.65),
      );
      expect(
        const DismissiblePageRebound.spring(),
        isNot(const DismissiblePageRebound.curve()),
      );
      expect(
        const DismissiblePageExit.momentum(),
        const DismissiblePageExit.momentum(),
      );
      expect(
        const DismissiblePageExit.momentum(),
        isNot(const DismissiblePageExit.curve(Curves.linear)),
      );
    });

    test('config objects validate their scalars', () {
      expect(
        () => DismissiblePageTransform(minScale: 1.5),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePageGesture(flingVelocity: 0),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePageGesture(cancelVelocity: -1),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePageGesture(flingMinDistance: 2),
        throwsAssertionError,
      );
    });

    test('gesture compares thresholds by value', () {
      expect(
        const DismissiblePageGesture(
          dismissThresholds: {DismissiblePageSide.down: 0.5},
        ),
        const DismissiblePageGesture(
          dismissThresholds: {DismissiblePageSide.down: 0.5},
        ),
      );
      expect(
        const DismissiblePageGesture(
          dismissThresholds: {DismissiblePageSide.down: 0.5},
        ),
        isNot(const DismissiblePageGesture()),
      );
    });

    test('custom background and radius resolve from progress', () {
      final background = DismissiblePageBackground.custom(
        (progress) => Color.lerp(Colors.red, Colors.blue, progress),
      );
      expect(background.isNone, isFalse);
      expect(background.resolveColor(0)!.toARGB32(), Colors.red.toARGB32());
      expect(background.resolveColor(1)!.toARGB32(), Colors.blue.toARGB32());
      expect(background.resolveColor(2)!.toARGB32(), Colors.blue.toARGB32());

      final radius = DismissiblePageRadius.custom((progress) => progress * 20);
      expect(radius.isNone, isFalse);
      expect(radius.resolveRadius(0.5), 10);
      expect(
        DismissiblePageRadius.custom((progress) => -5).resolveRadius(0),
        0,
      );
    });

    test('drag regions', () {
      const size = Size(400, 600);
      const top = DismissiblePageDragRegion.edge(DismissiblePageSide.up, 100);
      expect(top.contains(const Offset(10, 99), size, TextDirection.ltr), true);
      expect(
        top.contains(const Offset(10, 101), size, TextDirection.ltr),
        false,
      );
      const start =
          DismissiblePageDragRegion.edge(DismissiblePageSide.start, 50);
      expect(
        start.contains(const Offset(10, 300), size, TextDirection.ltr),
        true,
      );
      expect(
        start.contains(const Offset(10, 300), size, TextDirection.rtl),
        false,
      );
      expect(
        start.contains(const Offset(390, 300), size, TextDirection.rtl),
        true,
      );
    });
  });

  group('rebound curve duration', () {
    testWidgets('settles within the rebound duration', (tester) async {
      final offsets = <double>[];
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            motion: const DismissiblePageMotion(
              rebound: DismissiblePageRebound.curve(
                duration: Duration(milliseconds: 600),
              ),
            ),
            onDismissed: () {},
            onDragUpdate: (d) => offsets.add(d.offset.dy),
            child: const SizedBox.expand(),
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(400, 300));
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(offsets.last, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 400));
      expect(offsets.last, 0);
    });
  });

  group('onWillDismiss and onDismissStart', () {
    Widget page({
      required List<String> log,
      FutureOr<bool> Function()? onWillDismiss,
    }) =>
        _app(
          DismissiblePage(
            gesture: const DismissiblePageGesture(
              dismissThresholds: {DismissiblePageSide.down: 0.1},
            ),
            onWillDismiss: onWillDismiss,
            onDismissStart: () => log.add('start'),
            onDismissed: () => log.add('dismissed'),
            child: const SizedBox.expand(),
          ),
        );

    testWidgets('start comes right before dismissed', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(page(log: log));
      await _drag(tester, const Offset(0, 200));
      expect(log, ['start', 'dismissed']);
    });

    testWidgets('a synchronous false keeps the page', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(page(log: log, onWillDismiss: () => false));
      await _drag(tester, const Offset(0, 200));
      expect(log, isEmpty);
    });

    testWidgets('a synchronous true dismisses', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(page(log: log, onWillDismiss: () => true));
      await _drag(tester, const Offset(0, 200));
      expect(log, ['start', 'dismissed']);
    });

    testWidgets('a pending answer holds the page, then acts', (tester) async {
      final log = <String>[];
      final answer = Completer<bool>();
      final offsets = <double>[];
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            gesture: const DismissiblePageGesture(
              dismissThresholds: {DismissiblePageSide.down: 0.1},
            ),
            onWillDismiss: () => answer.future,
            onDismissStart: () => log.add('start'),
            onDismissed: () => log.add('dismissed'),
            onDragUpdate: (d) => offsets.add(d.offset.dy),
            child: const SizedBox.expand(),
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(400, 300));
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      final held = offsets.last;
      expect(held, greaterThan(0));
      expect(log, isEmpty);

      // A new drag is ignored while the question is open.
      await _drag(tester, const Offset(0, 100));
      expect(offsets.last, held);

      answer.complete(false);
      await tester.pumpAndSettle();
      expect(offsets.last, 0);
      expect(log, isEmpty);
    });

    testWidgets('a pending yes dismisses', (tester) async {
      final log = <String>[];
      final answer = Completer<bool>();
      await tester.pumpWidget(
        page(log: log, onWillDismiss: () => answer.future),
      );
      await _drag(tester, const Offset(0, 200));
      expect(log, isEmpty);
      answer.complete(true);
      await tester.pumpAndSettle();
      expect(log, ['start', 'dismissed']);
    });

    testWidgets('DismissiblePage.dismiss asks too', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            onWillDismiss: () => false,
            onDismissStart: () => log.add('start'),
            onDismissed: () => log.add('dismissed'),
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => DismissiblePage.dismiss(context),
                child: const Text('close'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();
      expect(log, isEmpty);
    });
  });

  group('onDragEvent', () {
    testWidgets('reports the whole lifecycle', (tester) async {
      final events = <DismissiblePageEvent>[];
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            onDragEvent: events.add,
            onDismissed: () {},
            child: const SizedBox.expand(),
          ),
        ),
      );
      await _drag(tester, const Offset(0, 40));
      expect(events.first, isA<DismissiblePageDragStartEvent>());
      expect(events.whereType<DismissiblePageDragUpdateEvent>(), isNotEmpty);
      expect(events.whereType<DismissiblePageDragEndEvent>(), hasLength(1));
    });
  });

  group('lockAxis', () {
    Future<Offset> dragDiagonally(WidgetTester tester, {required bool lock}) {
      var last = Offset.zero;
      return () async {
        await tester.pumpWidget(
          _app(
            DismissiblePage(
              direction: DismissiblePageDismissDirection.all,
              gesture: DismissiblePageGesture(lockAxis: lock),
              transform: const DismissiblePageTransform(dragSensitivity: 1),
              onDragUpdate: (d) => last = d.offset,
              onDismissed: () {},
              child: const SizedBox.expand(),
            ),
          ),
        );
        final gesture = await tester.startGesture(const Offset(400, 300));
        await gesture.moveBy(const Offset(30, 10));
        await tester.pump();
        await gesture.moveBy(const Offset(10, 40));
        await tester.pump();
        final result = last;
        await gesture.cancel();
        await tester.pumpAndSettle();
        return result;
      }();
    }

    testWidgets('sticks to the axis it started along', (tester) async {
      final offset = await dragDiagonally(tester, lock: true);
      expect(offset.dy, 0);
      expect(offset.dx, greaterThan(0));
    });

    testWidgets('moves freely without it', (tester) async {
      final offset = await dragDiagonally(tester, lock: false);
      expect(offset.dx, greaterThan(0));
      expect(offset.dy, greaterThan(0));
    });
  });

  group('dragRegion', () {
    Future<double> dragFrom(WidgetTester tester, Offset inPage) async {
      var dy = 0.0;
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            gesture: const DismissiblePageGesture(
              dragRegion: DismissiblePageDragRegion.edge(
                DismissiblePageSide.up,
                100,
              ),
            ),
            onDragUpdate: (d) => dy = d.offset.dy,
            onDismissed: () {},
            child: const SizedBox.expand(),
          ),
        ),
      );
      final top = tester.getTopLeft(find.byType(DismissiblePage));
      final gesture = await tester.startGesture(top + inPage);
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      final result = dy;
      await gesture.up();
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('drags that start inside move the page', (tester) async {
      expect(await dragFrom(tester, const Offset(50, 50)), greaterThan(0));
    });

    testWidgets('drags that start outside do not', (tester) async {
      expect(await dragFrom(tester, const Offset(50, 400)), 0);
    });
  });

  group('DismissiblePage.of', () {
    testWidgets('exposes state and dismisses', (tester) async {
      DismissiblePageHandle? handle;
      var dismissed = false;
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            onDismissed: () => dismissed = true,
            child: Builder(
              builder: (context) {
                handle = DismissiblePage.of(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      expect(handle!.isDragging, isFalse);
      expect(handle!.progress, 0);
      var notified = 0;
      handle!.addListener(() => notified++);
      final gesture = await tester.startGesture(const Offset(400, 300));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(handle!.isDragging, isTrue);
      expect(handle!.progress, greaterThan(0));
      expect(notified, greaterThan(0));
      await gesture.up();
      await tester.pumpAndSettle();

      handle!.dismiss();
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('maybeOf is null outside a page', (tester) async {
      var called = false;
      DismissiblePageHandle? handle;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            called = true;
            handle = DismissiblePage.maybeOf(context);
            return const SizedBox();
          },
        ),
      );
      expect(called, isTrue);
      expect(handle, isNull);
    });
  });

  group('semantics', () {
    testWidgets('a screen reader can dismiss the page', (tester) async {
      final semantics = tester.ensureSemantics();
      var dismissed = false;
      await tester.pumpWidget(
        _app(
          DismissiblePage(
            semanticLabel: 'Photo viewer',
            onDismissed: () => dismissed = true,
            child: const SizedBox.expand(),
          ),
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Photo viewer'));
      expect(node.label, 'Photo viewer');
      tester.semantics.dismiss(find.semantics.byLabel('Photo viewer'));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
      semantics.dispose();
    });
  });

  group('TransparentRoute', () {
    testWidgets('options reach the route', (tester) async {
      final route = TransparentRoute<void>(
        builder: (_) => const SizedBox(),
        barrierDismissible: false,
        opaque: true,
      );
      expect(route.barrierDismissible, isFalse);
      expect(route.opaque, isTrue);
      final defaults = TransparentRoute<void>(builder: (_) => const SizedBox());
      expect(defaults.barrierDismissible, isTrue);
      expect(defaults.opaque, isFalse);
    });

    testWidgets('transitionBuilder replaces the fade', (tester) async {
      var built = false;
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      unawaited(
        context.pushTransparentRoute<void>(
          const Text('page'),
          transitionBuilder: (context, animation, secondary, child) {
            built = true;
            return child;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(built, isTrue);
      expect(find.text('page'), findsOneWidget);
    });
  });
}
