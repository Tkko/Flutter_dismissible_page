import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should create SingleAxisDismissiblePage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DismissiblePage(
        onDismissed: () {},
        child: const FlutterLogo(),
      ),
    );

    expect(find.byType(SingleAxisDismissiblePage), findsOneWidget);
    expect(find.byType(MultiAxisDismissiblePage), findsNothing);
  });

  testWidgets('Should create MultiAxisDismissiblePage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DismissiblePage(
        direction: DismissiblePageDismissDirection.multi,
        onDismissed: () {},
        child: const FlutterLogo(),
      ),
    );

    expect(find.byType(SingleAxisDismissiblePage), findsNothing);
    expect(find.byType(MultiAxisDismissiblePage), findsOneWidget);
  });

  testWidgets('Should create DecoratedBox when disabled',
      (WidgetTester tester) async {
    const backgroundColor = Colors.greenAccent;
    await tester.pumpWidget(
      DismissiblePage(
        onDismissed: () {},
        backgroundColor: backgroundColor,
        disabled: true,
        child: const FlutterLogo(),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == backgroundColor,
      ),
      findsOneWidget,
    );
    expect(find.byType(SingleAxisDismissiblePage), findsNothing);
    expect(find.byType(MultiAxisDismissiblePage), findsNothing);
  });

  testWidgets('onDragUpdate is called', (WidgetTester tester) async {
    double dragValue = 0;

    await tester.pumpWidget(
      DismissiblePage(
        onDismissed: () {},
        onDragUpdate: (value) => dragValue = value.overallDragValue,
        child: const FlutterLogo(),
      ),
    );

    expect(dragValue, 0.0);

    await tester.drag(find.byType(DismissiblePage), const Offset(100, 100));

    expect(dragValue, isNot(equals(0.0)));
  });
}
