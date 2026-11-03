import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A masonry photo grid. Tapping a photo opens it full screen through a
/// [Hero]; drag it in any direction and it flies back into the grid.
class PhotoGalleryPage extends StatelessWidget {
  const PhotoGalleryPage({super.key});

  // Alternating heights give the grid its masonry rhythm.
  static const _heights = [210.0, 150.0, 170.0, 230.0];

  @override
  Widget build(BuildContext context) {
    final columns = <List<Widget>>[[], []];
    for (var i = 0; i < demoPhotos.length; i++) {
      columns[i % 2].add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PhotoTile(
            photo: demoPhotos[i],
            height: _heights[(i ~/ 2 + i) % _heights.length],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const DismissibleBackButton(),
        title: Text(
          'Photos',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(children: columns[0])),
            const SizedBox(width: 12),
            Expanded(child: Column(children: columns[1])),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.height});

  final DemoPhoto photo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushTransparentRoute(PhotoViewerPage(photo: photo)),
      child: Hero(
        tag: photo.url,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: DemoImage(photo.url),
          ),
        ),
      ),
    );
  }
}

class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({required this.photo, super.key});

  final DemoPhoto photo;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  // Chrome fades out as the photo is dragged away, like the system gallery.
  final _progress = ValueNotifier<double>(0);
  bool _liked = false;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;

    return DismissibleDemo(
      onDragUpdate: (details) => _progress.value = details.progress,
      // The Hero flight is the exit, so the page must not slide away too.
      exitsThroughHero: true,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Hero(
                tag: photo.url,
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DemoImage(photo.url),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (context, progress, child) => Opacity(
                opacity: (1 - progress * 2.5).clamp(0.0, 1.0),
                child: child,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _RoundButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _RoundButton(
                            icon: _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _liked ? const Color(0xffff5c8a) : null,
                            onTap: () => setState(() => _liked = !_liked),
                          ),
                          const SizedBox(width: 10),
                          const _RoundButton(icon: Icons.ios_share_rounded),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  photo.place,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Drag in any direction to let go',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white12,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color ?? Colors.white, size: 22),
        ),
      ),
    );
  }
}
