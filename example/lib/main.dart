import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: SimpleExample()));
}

/// This is a basic usage of DismissiblePage
/// For more examples check the demo/folder
class SimpleExample extends StatelessWidget {
  static const imagePath = 'assets/images/home_1.png';

  const SimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Simple Example'),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black.withValues(alpha: .85),
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
                const SecondPage(imagePath: imagePath),
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

  const SecondPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      // Start of the optional properties
      isFullScreen: false,
      enabled: true,
      borderRadius: const DismissiblePageRadius.fixed(10),
      transform: const DismissiblePageTransform(
        dragSensitivity: 1.0,
        maxTransformValue: .8,
        minScale: .8,
      ),
      direction: DismissiblePageDismissDirection.all,
      background: const DismissiblePageBackground.solid(Colors.black),
      gesture: const DismissiblePageGesture(
        dismissThresholds: {
          DismissiblePageSide.up: .2,
          DismissiblePageSide.down: .2,
          DismissiblePageSide.start: .3,
          DismissiblePageSide.end: .3,
        },
      ),
      motion: const DismissiblePageMotion(
        continueOnDismiss: true,
        thresholdHaptics: true,
      ),
      // End of the optional properties
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Hero(
                tag: imagePath,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              ...List.generate(40, (index) => index + 1).map((index) {
                return ListTile(
                  title: Text(
                    'Item $index',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
