import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: SimpleExample()));
}

/// This is a basic usage of DismissiblePage
/// For more examples check the demo/folder
class SimpleExample extends StatelessWidget {
  static const imagePath = 'assets/images/home_1.png';

  const SimpleExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Simple Example'),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black.withOpacity(.85),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: GestureDetector(
            onTap: () {
              // Use extension method to use [TransparentRoute]
              // This will push page without route background
              context.pushTransparentRoute(
                SecondPage(imagePath: imagePath),
              );
            },
            child: Hero(
              tag: imagePath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final String imagePath;

  const SecondPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      // Start of the optional properties
      isFullScreen: false,
      disabled: false,
      minRadius: 10,
      maxRadius: 10,
      dragSensitivity: .1,
      maxTransformValue: .8,
      direction: DismissiblePageDismissDirection.vertical,
      backgroundColor: Colors.black,
      dismissThresholds: {
        DismissiblePageDismissDirection.vertical: .2,
      },
      minScale: .8,
      startingOpacity: 1,
      reverseDuration: const Duration(milliseconds: 250),
      // End of the optional properties
      child: Scaffold(
        body: SingleChildScrollView(
          // Expected result For ClampingScrollPhysics (https://user-images.githubusercontent.com/26390946/194924545-1712b63b-2a25-4182-b731-db49ecc50c23.mov)
          // Expected result for BouncingScrollPhysics (https://user-images.githubusercontent.com/26390946/194924598-eb3d3d54-b1de-4ba1-a22a-52a08e3c25b3.mov)
          physics: ClampingScrollPhysics(),
          // physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Hero(
                tag: imagePath,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              ...List.generate(20, (index) => index + 1).map((index) {
                return ListTile(
                  title: Text(
                    'Item $index',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
