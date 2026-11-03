import 'package:dismissible_page_example/demo/models/demo_settings.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/chat.dart';
import 'package:dismissible_page_example/demo/scenarios/music_player.dart';
import 'package:dismissible_page_example/demo/scenarios/photo_gallery.dart';
import 'package:dismissible_page_example/demo/scenarios/share_sheet.dart';
import 'package:dismissible_page_example/demo/scenarios/shop.dart';
import 'package:dismissible_page_example/demo/scenarios/today.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:dismissible_page_example/demo/widgets/expanding_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> pumpApp(WidgetTester tester, Widget home) async {
  tester.view
    ..physicalSize = const Size(1080, 2280)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: home));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> dragAndSettle(
  WidgetTester tester,
  Finder finder,
  Offset delta,
) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  for (var i = 0; i < 12; i++) {
    await gesture.moveBy(delta / 12);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // Fonts are not available offline in tests; the fallback is fine.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // google_fonts reports missing font files as errors; they are irrelevant
  // to layout, so only real exceptions should fail a test.
  void ignoreFontErrors() {
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('google_fonts')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
  }

  setUp(ignoreFontErrors);

  testWidgets('home lists every real-world scenario', (tester) async {
    await pumpApp(tester, const DismissiblePageDemo());

    for (final title in [
      'Today stories',
      'Photo viewer',
      'Now playing',
      'Product page',
      'Chat thread',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }
  });

  group('every scenario screen is dismissible', () {
    // The card title on the home screen, and the tooltip of the screen's own
    // back button.
    const screens = {
      'Today stories': 'Close',
      'Photo viewer': 'Back',
      'Now playing': 'Back',
      'Product page': 'Back',
      'Chat thread': 'Back',
      'Share sheet': 'Back',
    };

    Future<void> openFromHome(WidgetTester tester, String title) async {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byType(DismissibleScreen), findsOneWidget);
    }

    for (final entry in screens.entries) {
      testWidgets('${entry.key}: swipe right and back button', (tester) async {
        await pumpApp(tester, const DismissiblePageDemo());

        await openFromHome(tester, entry.key);
        await dragAndSettle(
          tester,
          find.byType(DismissibleScreen),
          const Offset(900, 0),
        );
        expect(find.byType(DismissibleScreen), findsNothing);

        await openFromHome(tester, entry.key);
        await tester.tap(find.byTooltip(entry.value));
        await tester.pumpAndSettle();
        expect(find.byType(DismissibleScreen), findsNothing);
      });
    }
  });

  testWidgets('the shared settings apply to every scenario screen',
      (tester) async {
    final settings = DismissiblePageModel()..enabled = false;
    tester.view
      ..physicalSize = const Size(1080, 2280)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      DemoSettings(
        model: settings,
        child: const MaterialApp(home: DismissiblePageDemo()),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Product page'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Product page'));
    await tester.pumpAndSettle();
    expect(find.byType(DismissibleScreen), findsOneWidget);

    await dragAndSettle(
      tester,
      find.byType(DismissibleScreen),
      const Offset(900, 0),
    );
    expect(find.byType(DismissibleScreen), findsOneWidget);

    // The back button still closes it. Turn gestures back on, open the screen
    // again, and the same swipe now dismisses it.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(DismissibleScreen), findsNothing);

    settings.enabled = true;
    await tester.tap(find.text('Product page'));
    await tester.pumpAndSettle();
    await dragAndSettle(
      tester,
      find.byType(DismissibleScreen),
      const Offset(900, 0),
    );
    expect(find.byType(DismissibleScreen), findsNothing);
  });

  testWidgets('a Today card expands into its story and shrinks back',
      (tester) async {
    await pumpApp(tester, const TodayPage());

    await tester.tap(find.byType(Hero).first);
    await tester.pumpAndSettle();
    expect(find.byType(StoryPage), findsOneWidget);
    // The body is revealed once the header has grown.
    expect(find.textContaining('Long before sunrise'), findsOneWidget);

    await dragAndSettle(
      tester,
      find.byType(StoryPage),
      const Offset(0, 900),
    );
    expect(find.byType(StoryPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets(
      'ExpandingHero squares its corners opening and rounds them '
      'closing', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: ExpandingHero(
                tag: 'card',
                radius: 24,
                child: ColoredBox(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );

    Future<List<double>> sampleRadii() async {
      final radii = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final shuttle = find.byKey(ExpandingHero.shuttleKey);
        if (shuttle.evaluate().isEmpty) continue;
        // Text in the shuttle needs a Material, or it is drawn underlined.
        expect(
          find.ancestor(of: shuttle, matching: find.byType(Material)),
          findsWidgets,
        );
        radii.add(
          tester
              .widget<ClipRRect>(shuttle)
              .borderRadius
              .resolve(TextDirection.ltr)
              .topLeft
              .x,
        );
      }
      return radii;
    }

    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: SizedBox.expand(
            child: ExpandingHero(
              tag: 'card',
              child: ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
    final opening = await sampleRadii();
    await tester.pumpAndSettle();
    expect(opening, isNotEmpty, reason: 'no flight happened');
    expect(opening.first, greaterThan(opening.last));
    expect(opening.first, lessThanOrEqualTo(24));
    expect(opening.last, greaterThanOrEqualTo(0));

    navigator.currentState!.pop();
    final closing = await sampleRadii();
    await tester.pumpAndSettle();
    expect(closing, isNotEmpty, reason: 'no flight happened');
    expect(closing.first, lessThan(closing.last));
    expect(closing.last, greaterThan(opening.last));
  });

  testWidgets('photo viewer opens and is dragged away', (tester) async {
    await pumpApp(tester, const PhotoGalleryPage());

    await tester.tap(find.byType(Hero).first);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewerPage), findsOneWidget);

    await dragAndSettle(
      tester,
      find.byType(PhotoViewerPage),
      const Offset(0, 900),
    );
    expect(find.byType(PhotoViewerPage), findsNothing);
  });

  testWidgets('now playing closes with its chevron', (tester) async {
    await pumpApp(tester, const MusicHomePage());

    await tester.tap(find.byIcon(Icons.pause_rounded).first,
        warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('Midnight Drive').last);
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingPage), findsNothing);
  });

  testWidgets('product page scrolls, then dismisses from the top',
      (tester) async {
    await pumpApp(tester, const ShopPage());

    await tester.tap(find.text('Alpine Lake'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPage), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPage), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPage), findsOneWidget);

    await dragAndSettle(
      tester,
      find.byType(ProductPage),
      const Offset(0, 1200),
    );
    expect(find.byType(ProductPage), findsNothing);
  });

  testWidgets('chat sends a message and swipes back', (tester) async {
    await pumpApp(tester, const ChatListPage());

    await tester.tap(find.text('Nina Okafor'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'See you soon');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(find.text('See you soon'), findsOneWidget);

    await dragAndSettle(
      tester,
      find.byType(ChatPage),
      const Offset(900, 0),
    );
    expect(find.byType(ChatPage), findsNothing);
  });

  testWidgets('share sheet closes with Cancel and by tapping the scrim',
      (tester) async {
    await pumpApp(tester, const ArticlePage());

    await tester.tap(find.byIcon(Icons.ios_share_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ShareSheetPage), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(ShareSheetPage), findsNothing);

    await tester.tap(find.byIcon(Icons.ios_share_rounded));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(180, 40));
    await tester.pumpAndSettle();
    expect(find.byType(ShareSheetPage), findsNothing);
  });
}
