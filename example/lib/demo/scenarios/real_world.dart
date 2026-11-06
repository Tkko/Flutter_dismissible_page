import 'package:dismissible_page_example/demo/scenarios/chat.dart';
import 'package:dismissible_page_example/demo/scenarios/music_player.dart';
import 'package:dismissible_page_example/demo/scenarios/photo_gallery.dart';
import 'package:dismissible_page_example/demo/scenarios/share_sheet.dart';
import 'package:dismissible_page_example/demo/scenarios/today.dart';
import 'package:dismissible_page_example/demo/scenarios/shop.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:dismissible_page_example/demo/widgets/scenario_card.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';

/// The home screen section that opens one mini-app per real-world pattern.
class RealWorldScenarios extends StatelessWidget {
  const RealWorldScenarios({super.key});

  void _open(BuildContext context, Widget page) {
    context.pushTransparentRoute(DismissibleScreen(child: page));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Real-world patterns',
                style: DemoText.heading,
              ),
              const SizedBox(height: 4),
              Text(
                'Small apps that use a dismissible page the way yours would',
                style: DemoText.caption.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        ScenarioCard(
          title: 'Today stories',
          subtitle: 'Cards that expand into full pages, App Store style',
          icon: Icons.auto_stories_rounded,
          color: const Color(0xffff6b35),
          tags: const ['Expanding Hero', 'Rounded corners', 'Shrinks back'],
          onTap: () => _open(context, const TodayPage()),
        ),
        ScenarioCard(
          title: 'Photo viewer',
          subtitle: 'A gallery that opens photos full screen',
          icon: Icons.photo_library_rounded,
          color: const Color(0xff7b5cff),
          tags: const ['Hero', 'Any direction', 'Fading chrome'],
          onTap: () => _open(context, const PhotoGalleryPage()),
        ),
        ScenarioCard(
          title: 'Now playing',
          subtitle: 'A music sheet that follows your finger',
          icon: Icons.music_note_rounded,
          color: const Color(0xffff5c8a),
          tags: const ['Sheet', 'Rounded corners', 'Swipe-style close'],
          onTap: () => _open(context, const MusicHomePage()),
        ),
        ScenarioCard(
          title: 'Product page',
          subtitle: 'A long page you can still pull down to close',
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xff2ec4b6),
          tags: const ['Hero', 'Scrolling content', 'Pull from the top'],
          onTap: () => _open(context, const ShopPage()),
        ),
        ScenarioCard(
          title: 'Chat thread',
          subtitle: 'Swipe right anywhere to go back',
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xff0a84ff),
          tags: const ['Horizontal', 'Swipe back', 'Keyboard'],
          onTap: () => _open(context, const ChatListPage()),
        ),
        ScenarioCard(
          title: 'Share sheet',
          subtitle: 'A partial sheet over a dimmed scrim',
          icon: Icons.ios_share_rounded,
          color: const Color(0xffff9f0a),
          tags: const ['Scrim', 'Tap outside', 'Fling to close'],
          onTap: () => _open(context, const ArticlePage()),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
