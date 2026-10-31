import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> dragPage(
  WidgetTester tester,
  Offset delta, {
  Map<DismissiblePageSide, double> thresholds = const {},
  DismissiblePageDismissDirection direction =
      DismissiblePageDismissDirection.all,
  TextDirection textDirection = TextDirection.ltr,
  double maxTransformValue = 0.4,
  double sensitivity = 1,
}) async {
  var dismissed = false;
  DismissiblePageDragUpdateDetails? details;
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: DismissiblePage(
              key: UniqueKey(),
              direction: direction,
              dismissThresholds: thresholds,
              maxTransformValue: maxTransformValue,
              dragSensitivity: sensitivity,
              onDismissed: () => dismissed = true,
              onDragUpdate: (value) => details = value,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
  );
  final gesture =
      await tester.startGesture(tester.getCenter(find.byType(DismissiblePage)));
  for (var i = 0; i < 5; i++) {
    await gesture.moveBy(delta / 5);
    await tester.pump(const Duration(milliseconds: 200));
  }
  if (direction == DismissiblePageDismissDirection.all) {
    expect(details!.offset.dx, closeTo(delta.dx * sensitivity, 0.001));
    expect(details!.offset.dy, closeTo(delta.dy * sensitivity, 0.001));
  }
  await tester.pump(const Duration(seconds: 1));
  await gesture.moveBy(Offset.zero);
  await gesture.up();
  await tester.pumpAndSettle();
  return dismissed;
}

void main() {
  group('Directional thresholds', () {
    const thresholds = {
      DismissiblePageSide.up: 0.10,
      DismissiblePageSide.down: 0.30,
      DismissiblePageSide.start: 0.10,
      DismissiblePageSide.end: 0.30,
    };

    for (final textDirection in TextDirection.values) {
      testWidgets('selects all four sides in ${textDirection.name}',
          (tester) async {
        expect(
          await dragPage(
            tester,
            const Offset(0, -120),
            thresholds: thresholds,
            textDirection: textDirection,
          ),
          isTrue,
        );
        expect(
          await dragPage(
            tester,
            const Offset(0, 120),
            thresholds: thresholds,
            textDirection: textDirection,
          ),
          isFalse,
        );
        expect(
          await dragPage(
            tester,
            const Offset(-80, 0),
            thresholds: thresholds,
            textDirection: textDirection,
          ),
          textDirection == TextDirection.ltr,
        );
        expect(
          await dragPage(
            tester,
            const Offset(80, 0),
            thresholds: thresholds,
            textDirection: textDirection,
          ),
          textDirection == TextDirection.rtl,
        );
      });

      testWidgets(
          'one-way horizontal gestures use destination in ${textDirection.name}',
          (tester) async {
        final sign = textDirection == TextDirection.ltr ? 1.0 : -1.0;
        expect(
          await dragPage(
            tester,
            Offset(sign * 80, 0),
            thresholds: thresholds,
            direction: DismissiblePageDismissDirection.startToEnd,
            textDirection: textDirection,
          ),
          isFalse,
        );
        expect(
          await dragPage(
            tester,
            Offset(-sign * 80, 0),
            thresholds: thresholds,
            direction: DismissiblePageDismissDirection.endToStart,
            textDirection: textDirection,
          ),
          isTrue,
        );
      });
    }

    testWidgets('height thresholds are exact and independent of visual extent',
        (tester) async {
      for (final extent in [0.1, 0.8]) {
        for (final distance in [119.0, 120.0, 121.0]) {
          expect(
            await dragPage(
              tester,
              Offset(0, distance),
              thresholds: const {DismissiblePageSide.down: 0.20},
              maxTransformValue: extent,
            ),
            distance >= 120,
          );
        }
      }
    });

    testWidgets('width thresholds use page width, not height', (tester) async {
      for (final distance in [79.0, 80.0, 81.0]) {
        expect(
          await dragPage(
            tester,
            Offset(distance, 0),
            thresholds: const {DismissiblePageSide.end: 0.20},
          ),
          distance >= 80,
        );
      }
    });

    testWidgets('sensitivity affects displacement, not threshold units',
        (tester) async {
      expect(
        await dragPage(
          tester,
          const Offset(0, 200),
          thresholds: const {DismissiblePageSide.down: 0.20},
          sensitivity: 0.5,
        ),
        isFalse,
      );
    });

    testWidgets('missing sides default independently to 15 percent',
        (tester) async {
      for (final distance in [89.0, 90.0]) {
        expect(
          await dragPage(
            tester,
            Offset(0, distance),
            thresholds: const {DismissiblePageSide.up: 0.01},
          ),
          distance >= 90,
        );
      }
    });

    testWidgets('diagonal drags can dismiss through either axis',
        (tester) async {
      for (final thresholds in [
        const {DismissiblePageSide.end: 0.8, DismissiblePageSide.down: 0.15},
        const {DismissiblePageSide.end: 0.2, DismissiblePageSide.down: 0.8},
        const {DismissiblePageSide.end: 0.8, DismissiblePageSide.down: 0.8},
      ]) {
        expect(
          await dragPage(
            tester,
            const Offset(120, 120),
            thresholds: thresholds,
          ),
          thresholds.values.any((value) => value < 0.8),
        );
      }
    });

    testWidgets('threshold entries do not enable excluded directions',
        (tester) async {
      expect(
        await dragPage(
          tester,
          const Offset(120, -120),
          direction: DismissiblePageDismissDirection.down,
          thresholds: const {
            DismissiblePageSide.up: 0,
            DismissiblePageSide.end: 0,
          },
        ),
        isFalse,
      );
      expect(
        await dragPage(
          tester,
          const Offset(120, 120),
          direction: DismissiblePageDismissDirection.none,
          thresholds: const {DismissiblePageSide.end: 0},
        ),
        isFalse,
      );
    });

    testWidgets('zero threshold does not dismiss an untouched axis',
        (tester) async {
      expect(
        await dragPage(
          tester,
          const Offset(0, 30),
          thresholds: const {
            DismissiblePageSide.start: 0,
            DismissiblePageSide.end: 0,
            DismissiblePageSide.down: 1,
          },
        ),
        isFalse,
      );
    });

    testWidgets('asserts on invalid thresholds when building', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage(
            onDismissed: () {},
            dismissThresholds: const {DismissiblePageSide.down: 1.5},
            child: const SizedBox(),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);

      await tester.pumpWidget(
        MaterialApp(
          home: DismissiblePage.builder(
            onDismissed: () {},
            dismissThresholds: const {DismissiblePageSide.up: -0.1},
            builder: (_, __) => const SizedBox(),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    test('constructor asserts validate scalar configuration properties', () {
      expect(
        () => DismissiblePage(
          onDismissed: () {},
          minScale: -0.1,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage(
          onDismissed: () {},
          minScale: 1.1,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage(
          onDismissed: () {},
          maxTransformValue: -0.1,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage(
          onDismissed: () {},
          maxTransformValue: 1.1,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage(
          onDismissed: () {},
          dragSensitivity: 0,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage.builder(
          onDismissed: () {},
          minScale: -0.5,
          builder: (_, __) => const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage.builder(
          onDismissed: () {},
          maxTransformValue: 2,
          builder: (_, __) => const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => DismissiblePage.builder(
          onDismissed: () {},
          dragSensitivity: -1,
          builder: (_, __) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  testWidgets('builder preserves and disposes its internal controller',
      (tester) async {
    DismissiblePageScrollController? controller;
    Widget page({required bool enabled}) => MaterialApp(
          home: DismissiblePage.builder(
            enabled: enabled,
            onDismissed: () {},
            builder: (context, value) {
              controller = value;
              return ListView(
                controller: value,
                children: const [Text('Builder content')],
              );
            },
          ),
        );

    await tester.pumpWidget(page(enabled: false));
    final originalController = controller!;
    expect(originalController.hasClients, isTrue);
    await tester.pumpWidget(page(enabled: false));
    expect(controller, same(originalController));
    await tester.pumpWidget(page(enabled: true));
    expect(controller, same(originalController));
    await tester.pumpWidget(const SizedBox());
    expect(() => originalController.addListener(() {}), throwsFlutterError);
  });

  for (final textDirection in TextDirection.values) {
    for (final coordinated in [true, false]) {
      for (final physics in [
        const ClampingScrollPhysics(),
        if (coordinated) const BouncingScrollPhysics(),
      ]) {
        testWidgets(
            'horizontal edge thresholds follow ${textDirection.name}, coordinated: $coordinated, $physics',
            (tester) async {
          var dismissed = false;
          DismissiblePageDragUpdateDetails? details;
          final fallbackController = ScrollController();
          addTearDown(fallbackController.dispose);
          Widget list(ScrollController controller) => ListView(
                scrollDirection: Axis.horizontal,
                physics: physics,
                controller: controller,
                children: const [SizedBox(width: 1200)],
              );
          final page = coordinated
              ? DismissiblePage.builder(
                  direction: DismissiblePageDismissDirection.startToEnd,
                  dragSensitivity: 1,
                  dismissThresholds: const {
                    DismissiblePageSide.end: 0.1,
                    DismissiblePageSide.start: 1,
                  },
                  onDismissed: () => dismissed = true,
                  onDragUpdate: (value) => details = value,
                  builder: (_, controller) => list(controller),
                )
              : DismissiblePage(
                  direction: DismissiblePageDismissDirection.startToEnd,
                  dragSensitivity: 1,
                  dismissThresholds: const {
                    DismissiblePageSide.end: 0.1,
                    DismissiblePageSide.start: 1,
                  },
                  onDismissed: () => dismissed = true,
                  onDragUpdate: (value) => details = value,
                  child: list(fallbackController),
                );
          await tester.pumpWidget(
            MaterialApp(
              home: Directionality(
                textDirection: textDirection,
                child: Center(
                  child: SizedBox(width: 400, height: 600, child: page),
                ),
              ),
            ),
          );
          final delta = textDirection == TextDirection.ltr ? 20.0 : -20.0;
          final gesture = await tester
              .startGesture(tester.getCenter(find.byType(ListView)));
          for (var i = 0; i < 5; i++) {
            await gesture.moveBy(Offset(delta, 0));
            await tester.pump(const Duration(milliseconds: 200));
          }
          expect(details, isNotNull);
          expect(details!.offset.dx.sign, delta.sign);
          await tester.pump(const Duration(seconds: 1));
          await gesture.moveBy(Offset.zero);
          await gesture.up();
          await tester.pumpAndSettle();
          expect(dismissed, isTrue);
        });
      }
    }
  }

  testWidgets('builder uses but does not dispose an external controller',
      (tester) async {
    final controller = DismissiblePageScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: DismissiblePage.builder(
          controller: controller,
          onDismissed: () {},
          builder: (context, value) {
            expect(value, same(controller));
            return ListView(
              controller: value,
              children: const [Text('External content')],
            );
          },
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    expect(() => controller.addListener(() {}), returnsNormally);
  });

  test('drag details serialize progress under its new name', () {
    const details = DismissiblePageDragUpdateDetails(
      radius: 7,
      opacity: 1,
      progress: 0.5,
    );
    expect(details.progress, 0.5);
    expect(details.toMap()['progress'], 0.5);
    expect(details.toMap().containsKey('overallDragValue'), isFalse);
  });

  testWidgets('transparent route has defaults and returns typed results',
      (tester) async {
    final route = TransparentRoute<String>(
      builder: (_) => const Text('Route content'),
    );
    expect(route.backgroundColor, Colors.transparent);
    expect(route.transitionDuration, const Duration(milliseconds: 250));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 250));
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const Text('Home')),
    );
    final result = navigatorKey.currentState!.push(route);
    await tester.pumpAndSettle();
    expect(find.text('Route content'), findsOneWidget);
    navigatorKey.currentState!.pop('result');
    await tester.pumpAndSettle();
    expect(await result, 'result');

    final extensionResult =
        navigatorKey.currentContext!.pushTransparentRoute<int>(
      const Text('Extension content'),
    );
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop(42);
    await tester.pumpAndSettle();
    expect(await extensionResult, 42);
  });
}
