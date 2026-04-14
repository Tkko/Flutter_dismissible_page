// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:example/app/app.dart';
import 'package:example/demo/demo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(AppView), findsOneWidget);
    });
  });
}
