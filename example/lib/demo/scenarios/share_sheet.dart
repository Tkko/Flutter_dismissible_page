import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';

/// An article with a share sheet: a partial-height sheet over a dimmed
/// scrim. Drag it down, tap the scrim or press Cancel to close it.
class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  static const _paragraphs = [
    'Motion is how an interface explains itself. A page that follows your '
        'finger tells you it is physical, that it can be pushed away, and '
        'that it will come back if you change your mind.',
    'The best dismiss gestures borrow from the real world: they carry the '
        'speed you let go with, they settle without a hard stop, and they '
        'never trap you in a screen.',
    'Try dragging the share sheet from a few different heights, and flick it '
        'once. Notice how a quick flick closes it even from a short distance, '
        'while a slow drag has to travel further.',
  ];

  @override
  Widget build(BuildContext context) {
    final photo = demoPhotos[0];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const DismissibleBackButton(),
        actions: [
          IconButton(
            onPressed: () => context.pushTransparentRoute(
              const ShareSheetPage(title: 'Why motion matters'),
            ),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            'DESIGN NOTES',
            style: DemoText.microStrong
                .copyWith(letterSpacing: 2, color: const Color(0xff00a35a)),
          ),
          const SizedBox(height: 6),
          Text(
            'Why motion matters',
            style: DemoText.headlineLarge.copyWith(height: 1.15),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(height: 200, child: DemoImage(photo.url)),
          ),
          const SizedBox(height: 20),
          for (final paragraph in _paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                paragraph,
                style:
                    DemoText.body.copyWith(height: 1.7, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}

class ShareSheetPage extends StatelessWidget {
  const ShareSheetPage({required this.title, super.key});

  final String title;

  static const _targets = [
    ('Messages', Icons.chat_bubble_rounded, Color(0xff34c759)),
    ('Mail', Icons.mail_rounded, Color(0xff0a84ff)),
    ('Notes', Icons.sticky_note_2_rounded, Color(0xffffcc00)),
    ('More', Icons.more_horiz_rounded, Color(0xff8e8e93)),
  ];

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      // The scrim is already dimmed at rest.
      direction: DismissiblePageDismissDirection.down,
      background: DismissiblePageBackground.fadeOut(
        Colors.black,
        startOpacity: 0.5,
      ),
      // The sheet is part of the page, so the page itself must not scale or
      // round.
      borderRadius: const DismissiblePageRadius.none(),
      minScale: 1,
      child: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => DismissiblePage.dismiss(context),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Share',
                            style: DemoText.heading,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: DemoText.caption
                                .copyWith(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final (label, icon, color) in _targets)
                              Column(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(icon, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    label,
                                    style: DemoText.label,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.link_rounded),
                          title: const Text(
                            'Copy link',
                            style: DemoText.plain,
                          ),
                          onTap: () => DismissiblePage.dismiss(context),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xfff2f3f7),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => DismissiblePage.dismiss(context),
                            child: const Text(
                              'Cancel',
                              style: DemoText.plainSemiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
