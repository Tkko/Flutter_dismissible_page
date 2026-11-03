import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<double>> _dragAndRelease(
  WidgetTester tester, {
  required DismissiblePageMotion motion,
  double drag = 40,
  VoidCallback? onDismissed,
}) async {
  final offsets = <double>[];
  await tester.pumpWidget(
    MaterialApp(
      home: DismissiblePage(
        motion: motion,
        gesture: const DismissiblePageGesture(
          dismissThresholds: {DismissiblePageSide.down: 0.5},
        ),
        onDismissed: onDismissed ?? () {},
        onDragUpdate: (details) => offsets.add(details.offset.dy),
        child: const SizedBox.expand(),
      ),
    ),
  );
  final gesture = await tester.startGesture(const Offset(200, 300));
  await gesture.moveBy(Offset(0, drag));
  await tester.pump();
  await gesture.up();
  return offsets;
}

/// Drags [dragPx], then flicks [flickPx] at [flickSpeed] finger px/s, and
/// returns whether the page was dismissed.
Future<bool> _flick(
  WidgetTester tester, {
  required double dragPx,
  required double flickPx,
  required double flickSpeed,
  DismissiblePageMotion motion = const DismissiblePageMotion(),
  DismissiblePageGesture pageGesture = const DismissiblePageGesture(),
  Duration? dragStep,
}) async {
  var dismissed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: DismissiblePage(
        motion: motion,
        gesture: pageGesture,
        onDismissed: () => dismissed = true,
        child: const SizedBox.expand(),
      ),
    ),
  );
  // Unless told otherwise, the drag runs at the flick's speed so the
  // velocity estimate is steady.
  final dragInterval = dragStep ??
      Duration(
        microseconds: (dragPx.abs() / 10 / flickSpeed * 1e6).round(),
      );
  var time = Duration.zero;
  final gesture = await tester.startGesture(const Offset(200, 100));
  for (var i = 0; i < 10; i++) {
    time += dragInterval;
    await gesture.moveBy(Offset(0, dragPx / 10), timeStamp: time);
    await tester.pump(dragInterval);
  }
  final step = flickPx / 6;
  final interval =
      Duration(milliseconds: (step.abs() / flickSpeed * 1000).round());
  for (var i = 0; i < 6; i++) {
    time += interval;
    await gesture.moveBy(Offset(0, step), timeStamp: time);
    await tester.pump(interval);
  }
  await gesture.up(timeStamp: time);
  await tester.pumpAndSettle();
  return dismissed;
}

void main() {
  group('rebound', () {
    testWidgets('critically damped spring never crosses the origin',
        (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(),
      );
      await tester.pumpAndSettle();

      expect(offsets.last, 0);
      expect(offsets.every((dy) => dy >= 0), isTrue);
    });

    testWidgets('bouncy spring overshoots the origin', (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(
          rebound: DismissiblePageRebound.bouncy(),
        ),
      );
      await tester.pumpAndSettle();

      expect(offsets.last, 0);
      expect(offsets.any((dy) => dy < 0), isTrue);
    });

    testWidgets('curve rebound settles within reverseDuration', (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(
          rebound: DismissiblePageRebound.curve(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(offsets.last, 0);
    });
  });

  group('continueOnDismiss', () {
    testWidgets('carries the page off-screen while onDismissed runs',
        (tester) async {
      var dismissed = 0;
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(continueOnDismiss: true),
        drag: 500,
        onDismissed: () => dismissed++,
      );
      final releaseOffset = offsets.last;
      await tester.pumpAndSettle();

      expect(dismissed, 1);
      expect(
        offsets.last,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
      expect(offsets.last, greaterThan(releaseOffset));
    });

    testWidgets('stays put when disabled', (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(),
        drag: 500,
      );
      final releaseOffset = offsets.last;
      await tester.pumpAndSettle();

      expect(offsets.last, releaseOffset);
    });
  });

  group('fling', () {
    // 100px drag moves the page 70px, well short of the 150px threshold.
    testWidgets('a fast outward flick dismisses below the threshold',
        (tester) async {
      expect(
        await _flick(tester, dragPx: 100, flickPx: 30, flickSpeed: 2500),
        isTrue,
      );
    });

    testWidgets('a fast flick from a near-resting page does not dismiss',
        (tester) async {
      // 30px drag moves the page 21px, under the 10% minimum distance.
      expect(
        await _flick(tester, dragPx: 30, flickPx: 30, flickSpeed: 2500),
        isFalse,
      );
    });

    testWidgets('flingVelocity and flingMinDistance are configurable',
        (tester) async {
      // 700 finger px/s is 490 page px/s: a fling only with a lower speed.
      expect(
        await _flick(
          tester,
          dragPx: 100,
          flickPx: 30,
          flickSpeed: 700,
          pageGesture: const DismissiblePageGesture(flingVelocity: 300),
        ),
        isTrue,
      );
    });

    testWidgets('infinite flingVelocity dismisses by distance only',
        (tester) async {
      expect(
        await _flick(
          tester,
          dragPx: 100,
          flickPx: 30,
          flickSpeed: 4000,
          pageGesture: const DismissiblePageGesture(
            flingVelocity: double.infinity,
          ),
        ),
        isFalse,
      );
    });

    testWidgets('a slow outward release does not', (tester) async {
      expect(
        await _flick(tester, dragPx: 100, flickPx: 30, flickSpeed: 300),
        isFalse,
      );
    });

    testWidgets('speed is measured in page pixels, not finger pixels',
        (tester) async {
      // 700 finger px/s is 490 page px/s at the default 0.7 sensitivity.
      expect(
        await _flick(tester, dragPx: 100, flickPx: 30, flickSpeed: 700),
        isFalse,
      );
    });

    // 300px drag moves the page 210px, past the 108px threshold.
    testWidgets(
        'drifting back towards the origin cancels a past-threshold '
        'release', (tester) async {
      // 600 finger px/s is 420 page px/s, above the 300 cancel speed.
      expect(
        await _flick(tester, dragPx: 300, flickPx: -60, flickSpeed: 600),
        isFalse,
      );
    });

    testWidgets('a hesitation too slow to count still dismisses',
        (tester) async {
      // 150 finger px/s is 105 page px/s, below the cancel speed.
      expect(
        await _flick(tester, dragPx: 300, flickPx: -6, flickSpeed: 150),
        isTrue,
      );
    });

    testWidgets('cancelVelocity is configurable', (tester) async {
      expect(
        await _flick(
          tester,
          dragPx: 300,
          flickPx: -60,
          flickSpeed: 600,
          pageGesture: const DismissiblePageGesture(
            cancelVelocity: double.infinity,
          ),
        ),
        isTrue,
      );
    });

    testWidgets('a hard flick back cancels a drag past the threshold',
        (tester) async {
      // 500px drag then a 120px flick back leaves the page 266px out, past
      // the 150px threshold.
      expect(
        await _flick(tester, dragPx: 500, flickPx: -120, flickSpeed: 3000),
        isFalse,
      );
    });

    testWidgets('a slow release past the threshold still dismisses',
        (tester) async {
      expect(
        await _flick(
          tester,
          dragPx: 300,
          flickPx: -6,
          flickSpeed: 100,
          dragStep: const Duration(milliseconds: 100),
        ),
        isTrue,
      );
    });
  });

  group('DismissiblePage.dismiss', () {
    Future<(List<double>, List<double>, int)> pumpDismissible(
      WidgetTester tester, {
      DismissiblePageDismissDirection direction =
          DismissiblePageDismissDirection.vertical,
      DismissiblePageSide? side,
      int calls = 1,
    }) async {
      final dys = <double>[];
      final dxs = <double>[];
      var dismissed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            direction: direction,
            onDismissed: () => dismissed++,
            onDragUpdate: (details) {
              dys.add(details.offset.dy);
              dxs.add(details.offset.dx);
            },
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => DismissiblePage.dismiss(context, side: side),
                child: const Text('close'),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < calls; i++) {
        await tester.tap(find.text('close'));
        await tester.pump();
      }
      // Frame-sized steps, so the short wind-up is sampled.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      return (dys, dxs, dismissed);
    }

    testWidgets('leaves downwards with a small wind-up, once', (tester) async {
      final (dys, _, dismissed) = await pumpDismissible(tester, calls: 2);

      expect(dismissed, 1);
      expect(dys.any((dy) => dy < 0), isTrue, reason: 'no wind-up');
      expect(
        dys.last,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
    });

    testWidgets('side overrides the direction', (tester) async {
      final (dys, _, _) = await pumpDismissible(
        tester,
        side: DismissiblePageSide.up,
      );

      expect(
        dys.last,
        -tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
    });

    testWidgets('horizontal pages leave towards the end', (tester) async {
      final (_, dxs, _) = await pumpDismissible(
        tester,
        direction: DismissiblePageDismissDirection.horizontal,
      );

      expect(
        dxs.last,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
    });

    testWidgets('returns false outside a DismissiblePage', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(DismissiblePage.dismiss(captured), isFalse);
    });
  });

  group('release physics', () {
    testWidgets('a slow release accelerates away instead of lurching',
        (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(continueOnDismiss: true),
        drag: 500,
      );
      final atRelease = offsets.last;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));

      // The page is 600px tall. Two frames in, it has barely started moving.
      final remaining = 600 - atRelease;
      expect(offsets.last - atRelease, lessThan(remaining * 0.05));

      await tester.pumpAndSettle();
      expect(offsets.last, 600);
    });

    testWidgets('willDismiss turns on once the threshold is passed',
        (tester) async {
      final flags = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            // 0.5 of 600px, so 300px of page movement.
            gesture: const DismissiblePageGesture(
              dismissThresholds: {DismissiblePageSide.down: 0.5},
            ),
            onDismissed: () {},
            onDragUpdate: (details) => flags.add(details.willDismiss),
            child: const SizedBox.expand(),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(flags.last, isFalse);
      await gesture.moveBy(const Offset(0, 400));
      await tester.pump();
      expect(flags.last, isTrue);
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();
      expect(flags.last, isFalse);
      await gesture.cancel();
      await tester.pumpAndSettle();
    });
  });

  group('exit', () {
    const linear200 = DismissiblePageExit.curve(
      Curves.linear,
      duration: Duration(milliseconds: 200),
    );

    testWidgets(
        'a curve exit leaves along its curve and duration after a '
        'swipe', (tester) async {
      final offsets = await _dragAndRelease(
        tester,
        motion: const DismissiblePageMotion(
          continueOnDismiss: true,
          exit: linear200,
        ),
        drag: 500,
      );
      final atRelease = offsets.last;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Linear over 200ms: halfway through, half the 250px that were left.
      final travelled = (offsets.last - atRelease) / (600 - atRelease);
      expect(travelled, closeTo(0.5, 0.1));

      await tester.pump(const Duration(milliseconds: 150));
      expect(offsets.last, 600);
    });

    testWidgets('dismiss() uses the exit curve and duration', (tester) async {
      final offsets = <double>[];
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            motion: const DismissiblePageMotion(exit: linear200),
            onDismissed: () {},
            onDragUpdate: (details) => offsets.add(details.offset.dy),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Linear over 200ms: halfway through, half of the 600px page height.
      expect(offsets.last, closeTo(300, 60));

      await tester.pump(const Duration(milliseconds: 150));
      expect(offsets.last, 600);
    });

    test('exits compare by value', () {
      expect(
        const DismissiblePageExit.momentum(),
        const DismissiblePageExit.momentum(),
      );
      expect(linear200, isNot(const DismissiblePageExit.momentum()));
      expect(
        const DismissiblePageMotion(exit: linear200),
        isNot(const DismissiblePageMotion()),
      );
    });
  });

  group('thresholdHaptics', () {
    testWidgets('fires when the threshold is crossed in either direction',
        (tester) async {
      var haptics = 0;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics++;
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            motion: const DismissiblePageMotion(thresholdHaptics: true),
            gesture: const DismissiblePageGesture(
              dismissThresholds: {DismissiblePageSide.down: 0.1},
            ),
            onDismissed: () {},
            child: const SizedBox.expand(),
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(200, 300));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      expect(haptics, 0);
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(haptics, 1);
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();
      expect(haptics, 2);
      await gesture.cancel();
      await tester.pumpAndSettle();
    });
  });
}
