import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/demo_image.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:dismissible_page_example/demo/widgets/expanding_hero.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A small print shop. The product page is a long, scrollable screen: pull
/// down while it is at the top and it dismisses, otherwise it just scrolls.
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f4f0),
      appBar: AppBar(
        backgroundColor: const Color(0xfff6f4f0),
        leading: const DismissibleBackButton(),
        title: Text(
          'Prints',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: demoProducts.length,
        itemBuilder: (context, index) =>
            _ProductCard(product: demoProducts[index]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final DemoProduct product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushTransparentRoute(ProductPage(product: product)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ExpandingHero(
                tag: product.tag,
                radius: 18,
                child: DemoImage(product.photo.url),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${product.price}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({required this.product, super.key});

  final DemoProduct product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  static const _sizes = ['A4', 'A3', 'A2'];
  static const _reviews = [
    ('Mira', 'Colors are even better in person.'),
    ('Jonas', 'Arrived flat and perfectly packed.'),
    ('Aiko', 'Looks stunning above my desk.'),
    ('Dario', 'Bought a second one as a gift.'),
    ('Lena', 'The paper has a lovely texture.'),
    ('Omar', 'Worth every cent.'),
  ];

  int _size = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return DismissibleDemo(
      // Pulling down from the top is how a product page closes.
      direction: DismissiblePageDismissDirection.down,
      // The Hero flight is the exit, so the page must not slide away too.
      exitsThroughHero: true,
      child: Scaffold(
        backgroundColor: const Color(0xfff6f4f0),
        body: Stack(
          children: [
            // A plain ListView: the page picks up its scroll position, so a
            // pull-down only dismisses once the list is back at the top.
            ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: ExpandingHero(
                    tag: product.tag,
                    child: DemoImage(product.photo.url),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '\$${product.price}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xffffb400),
                            size: 18,
                          ),
                          Text(
                            ' 4.9  ·  218 reviews',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${product.blurb} Ships flat in a protective '
                        'sleeve within two working days.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Size',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          for (var i = 0; i < _sizes.length; i++)
                            ChoiceChip(
                              label: Text(_sizes[i]),
                              selected: _size == i,
                              onSelected: (_) => setState(() => _size = i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reviews',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      for (final (name, text) in _reviews)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: Text(name[0]),
                          ),
                          title: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(text),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.black38,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00f6f4f0), Color(0xfff6f4f0)],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Add to cart  ·  \$${product.price}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
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
