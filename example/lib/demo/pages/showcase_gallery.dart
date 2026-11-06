import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';

/// Interactive gallery showcasing all possible child widget scenarios
/// inside a [DismissiblePage]:
/// 1. Non-scrollable content (Image / Card / Layout)
/// 2. Basic ListView (vertical scrolling)
/// 3. CustomScrollView with Slivers (SliverAppBar, SliverGrid, SliverList)
/// 4. Horizontal PageView with PageScrollPhysics
/// 5. GridView (2D grid layout)
/// 6. TabBarView with multiple independent scrollable tabs
class ShowcaseGallery extends StatelessWidget {
  const ShowcaseGallery({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Child Widget Scenarios',
                style: DemoText.heading,
              ),
              const SizedBox(height: 4),
              Text(
                'Verify seamless dismiss coordination across all widget types',
                style: DemoText.caption.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        _ShowcaseCard(
          title: '1. Non-Scrollable Widget',
          subtitle: 'Static card/image driven directly by root Pan gestures',
          heroTag: 'showcase-1',
          icon: Icons.image_outlined,
          color: const Color(0xff5c6bc0),
          onTap: () {
            context.pushTransparentRoute(
              NonScrollableShowcasePage(pageModel: pageModel),
            );
          },
        ),
        _ShowcaseCard(
          title: '2. Standard ListView',
          subtitle:
              'Single-axis list view with edge dismissal and mid-drag lock',
          heroTag: 'showcase-2',
          icon: Icons.view_agenda_outlined,
          color: const Color(0xff26a69a),
          onTap: () {
            context.pushTransparentRoute(
              ListViewShowcasePage(pageModel: pageModel),
            );
          },
        ),
        _ShowcaseCard(
          title: '3. CustomScrollView & Slivers',
          subtitle:
              'Floating SliverAppBar, SliverGrid, and SliverList combined',
          heroTag: 'showcase-3',
          icon: Icons.layers_outlined,
          color: const Color(0xffef5350),
          onTap: () {
            context.pushTransparentRoute(
              SliversShowcasePage(pageModel: pageModel),
            );
          },
        ),
        _ShowcaseCard(
          title: '4. Horizontal PageView',
          subtitle:
              'Multi-card carousel with page snapping and start/end edge dismiss',
          heroTag: 'showcase-4',
          icon: Icons.view_carousel_outlined,
          color: const Color(0xffab47bc),
          onTap: () {
            context.pushTransparentRoute(
              PageViewShowcasePage(pageModel: pageModel),
            );
          },
        ),
        _ShowcaseCard(
          title: '5. GridView',
          subtitle: '2-column responsive grid view with pull-to-dismiss',
          heroTag: 'showcase-5',
          icon: Icons.grid_view_outlined,
          color: const Color(0xffff7043),
          onTap: () {
            context.pushTransparentRoute(
              GridViewShowcasePage(pageModel: pageModel),
            );
          },
        ),
        _ShowcaseCard(
          title: '6. TabBarView (Multi-Tab)',
          subtitle: 'Nested tabs with independent scroll positions',
          heroTag: 'showcase-6',
          icon: Icons.tab_outlined,
          color: const Color(0xff42a5f5),
          onTap: () {
            context.pushTransparentRoute(
              TabBarViewShowcasePage(pageModel: pageModel),
            );
          },
        ),
      ],
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.title,
    required this.subtitle,
    required this.heroTag,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String heroTag;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              ShowcaseIcon(
                tag: heroTag,
                icon: icon,
                color: color,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DemoText.bodyStrong,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: DemoText.label.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: card,
    );
  }
}

/// The tinted icon tile of a gallery card. It is a [Hero], so it flies from
/// the card into the opened page and, when that page is dismissed, from
/// wherever the drag left it back to the card.
class ShowcaseIcon extends StatelessWidget {
  const ShowcaseIcon({
    required this.tag,
    required this.icon,
    required this.color,
    this.size = 40,
    this.onColoredBackground = false,
    super.key,
  });

  final String tag;
  final IconData icon;
  final Color color;
  final double size;

  /// Draws a white tile, for use on a bar that is the same color as [color].
  final bool onColoredBackground;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            onColoredBackground ? Colors.white : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(icon, color: color, size: size / 2),
    );
    return Hero(tag: tag, child: tile);
  }
}

/// App bar leading slot that receives the card's [ShowcaseIcon] hero.
class ShowcaseLeading extends StatelessWidget {
  const ShowcaseLeading({
    required this.tag,
    required this.icon,
    required this.color,
    this.onColoredBackground = false,
    super.key,
  });

  final String tag;
  final IconData icon;
  final Color color;
  final bool onColoredBackground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ShowcaseIcon(
        tag: tag,
        icon: icon,
        color: color,
        onColoredBackground: onColoredBackground,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Non-Scrollable Widget Showcase
// ---------------------------------------------------------------------------
class NonScrollableShowcasePage extends StatelessWidget {
  const NonScrollableShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShowcaseIcon(
                  tag: 'showcase-1',
                  icon: Icons.image_outlined,
                  color: Color(0xff5c6bc0),
                  size: 88,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Non-Scrollable Widget',
                  style: DemoText.heading,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a simple Column/Container. Drag anywhere on the card or background to dismiss the route.',
                  textAlign: TextAlign.center,
                  style: DemoText.caption.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                // A Builder, so the context is below the DismissiblePage.
                Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: () => DismissiblePage.dismiss(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5c6bc0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Standard ListView Showcase
// ---------------------------------------------------------------------------
class ListViewShowcasePage extends StatelessWidget {
  const ListViewShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      child: Scaffold(
        appBar: AppBar(
          leading: const ShowcaseLeading(
            tag: 'showcase-2',
            icon: Icons.view_agenda_outlined,
            color: Color(0xff26a69a),
          ),
          title: const Text(
            'ListView Showcase',
            style: DemoText.subheading,
          ),
        ),
        body: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color(0xff26a69a).withValues(alpha: 0.15),
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    color: Color(0xff26a69a),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('List Item $index'),
              subtitle: Text(
                index == 0
                    ? 'Drag downward from here to dismiss'
                    : 'Mid-list drag scrolls content normally',
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. CustomScrollView & Slivers Showcase
// ---------------------------------------------------------------------------
class SliversShowcasePage extends StatelessWidget {
  const SliversShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              leading: const ShowcaseLeading(
                tag: 'showcase-3',
                icon: Icons.layers_outlined,
                color: Color(0xffef5350),
                onColoredBackground: true,
              ),
              backgroundColor: const Color(0xffef5350),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Slivers Showcase',
                  style: DemoText.lead,
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffef5350), Color(0xffff8a80)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.layers, size: 64, color: Colors.white30),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'SliverGrid Section',
                  style: DemoText.lead,
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text('Grid #$index'),
                ),
                childCount: 6,
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'SliverList Section',
                  style: DemoText.lead,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  title: Text('Sliver Row $index'),
                  subtitle:
                      const Text('Coordinates with DismissiblePage physics'),
                ),
                childCount: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Horizontal PageView Showcase
// ---------------------------------------------------------------------------
class PageViewShowcasePage extends StatefulWidget {
  const PageViewShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  State<PageViewShowcasePage> createState() => _PageViewShowcasePageState();
}

class _PageViewShowcasePageState extends State<PageViewShowcasePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: widget.pageModel,
      child: Scaffold(
        appBar: AppBar(
          leading: const ShowcaseLeading(
            tag: 'showcase-4',
            icon: Icons.view_carousel_outlined,
            color: Color(0xffab47bc),
          ),
          title: Text(
            'PageView Showcase (Page ${_currentPage + 1}/3)',
            style: DemoText.lead,
          ),
        ),
        body: PageView.builder(
          controller: _controller,
          onPageChanged: (page) => setState(() => _currentPage = page),
          itemCount: 3,
          itemBuilder: (context, index) {
            final colors = [
              const Color(0xffab47bc),
              const Color(0xff29b6f6),
              const Color(0xff66bb6a),
            ];
            return Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors[index].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors[index], width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_carousel, size: 72, color: colors[index]),
                    const SizedBox(height: 16),
                    Text(
                      'Page ${index + 1}',
                      style: DemoText.titleLarge.copyWith(color: colors[index]),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        index == 0
                            ? 'Swipe left for next page.\nSwipe right to dismiss!'
                            : 'Swipe between pages normally.',
                        textAlign: TextAlign.center,
                        style:
                            DemoText.bodySmall.copyWith(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. GridView Showcase
// ---------------------------------------------------------------------------
class GridViewShowcasePage extends StatelessWidget {
  const GridViewShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      child: Scaffold(
        appBar: AppBar(
          leading: const ShowcaseLeading(
            tag: 'showcase-5',
            icon: Icons.grid_view_outlined,
            color: Color(0xffff7043),
          ),
          title: const Text(
            'GridView Showcase',
            style: DemoText.subheading,
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.grid_on, color: Colors.deepOrange),
                    const SizedBox(height: 8),
                    Text(
                      'Card #$index',
                      style: DemoText.bodyStrong,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. TabBarView Showcase
// ---------------------------------------------------------------------------
class TabBarViewShowcasePage extends StatelessWidget {
  const TabBarViewShowcasePage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return DismissibleDemo(
      pageModel: pageModel,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: const ShowcaseLeading(
              tag: 'showcase-6',
              icon: Icons.tab_outlined,
              color: Color(0xff42a5f5),
            ),
            title: const Text(
              'TabBarView Showcase',
              style: DemoText.subheading,
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Feed'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: 30,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.feed),
                  title: Text('Feed Post #$index'),
                  subtitle: const Text('Pull down at top to dismiss'),
                ),
              ),
              ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text('Profile Activity #$index'),
                  subtitle: const Text('Independent tab scroll'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
