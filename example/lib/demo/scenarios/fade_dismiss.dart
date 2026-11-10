import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:flutter/material.dart';

/// A real-world example demonstrating how to fade out the page content
/// smoothly as the user drags it away, using [DismissiblePage.of] and
/// Flutter's built-in [ListenableBuilder].
class FadeDismissPage extends StatelessWidget {
  const FadeDismissPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      direction: DismissiblePageDismissDirection.down,
      background: const DismissiblePageBackground.transition(
        from: Colors.black87,
        to: Colors.transparent,
      ),
      child: Builder(
        builder: (context) {
          final handle = DismissiblePage.of(context);

          // ListenableBuilder updates Opacity whenever the page moves.
          // The child widget is cached and never rebuilt during drag ticks!
          return ListenableBuilder(
            listenable: handle,
            builder: (context, child) => Opacity(
              opacity: (1.0 - handle.progress).clamp(0.0, 1.0),
              child: child,
            ),
            child: _FadeDismissContent(handle: handle),
          );
        },
      ),
    );
  }
}

class _FadeDismissContent extends StatelessWidget {
  const _FadeDismissContent({required this.handle});

  final DismissiblePageHandle handle;

  @override
  Widget build(BuildContext context) {
    final photo = demoPhotos[0];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const DismissibleBackButton(),
        title: const Text('Fade on dismiss', style: DemoText.title),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Live opacity meter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xfff5f6f9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: ListenableBuilder(
              listenable: handle,
              builder: (context, _) {
                final opacity = (1.0 - handle.progress).clamp(0.0, 1.0);
                return Row(
                  children: [
                    const Icon(Icons.opacity_rounded, color: Color(0xff00d573)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Content Opacity',
                            style: DemoText.caption
                                .copyWith(color: Colors.black54),
                          ),
                          Text(
                            '${(opacity * 100).toInt()}% (${opacity.toStringAsFixed(2)})',
                            style: DemoText.subheadingMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: handle.isDragging
                            ? const Color(0xff00d573).withValues(alpha: 0.15)
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        handle.isDragging ? 'Dragging' : 'At rest',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: handle.isDragging
                              ? const Color(0xff00a35a)
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(height: 220, child: DemoImage(photo.url)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fading out while dismissing',
            style: DemoText.titleXLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull this page down. Notice how the foreground content fades away '
            'smoothly while the underlying screen remains visible.',
            style: DemoText.body.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff1e1e2e),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '// How it works:',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xffa6adc8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'final handle = DismissiblePage.of(context);\n'
                  'return ListenableBuilder(\n'
                  '  listenable: handle,\n'
                  '  builder: (context, child) => Opacity(\n'
                  '    opacity: (1 - handle.progress).clamp(0, 1),\n'
                  '    child: child,\n'
                  '  ),\n'
                  '  child: MyPageContent(), // cached, 0 rebuilds!\n'
                  ');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xffcdd6f4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
