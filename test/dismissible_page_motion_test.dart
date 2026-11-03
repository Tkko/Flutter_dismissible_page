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
        dismissThresholds: const {DismissiblePageSide.down: 0.5},
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
  Duration? dragStep,
}) async {
  var dismissed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: DismissiblePage(
        motion: motion,
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
          motion: const DismissiblePageMotion(flingVelocity: 300),
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
          motion: const DismissiblePageMotion(
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
            dismissThresholds: const {DismissiblePageSide.down: 0.1},
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
