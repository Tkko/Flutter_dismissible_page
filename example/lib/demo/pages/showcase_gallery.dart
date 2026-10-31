import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              Text(
                'Child Widget Scenarios',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Verify seamless dismiss coordination across all widget types',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        _ShowcaseCard(
          title: '1. Non-Scrollable Widget',
          subtitle: 'Static card/image driven directly by root Pan gestures',
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
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
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
                const Icon(
                  Icons.touch_app_rounded,
                  size: 64,
                  color: Color(0xff5c6bc0),
                ),
                const SizedBox(height: 16),
                Text(
                  'Non-Scrollable Widget',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a simple Column/Container. Drag anywhere on the card or background to dismiss the route.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
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
          title: Text(
            'ListView Showcase',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
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
              backgroundColor: const Color(0xffef5350),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Slivers Showcase',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'SliverGrid Section',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'SliverList Section',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
          title: Text(
            'PageView Showcase (Page ${_currentPage + 1}/3)',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors[index],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        index == 0
                            ? 'Swipe left for next page.\nSwipe right to dismiss!'
                            : 'Swipe between pages normally.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
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
          title: Text(
            'GridView Showcase',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
            title: Text(
              'TabBarView Showcase',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
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
