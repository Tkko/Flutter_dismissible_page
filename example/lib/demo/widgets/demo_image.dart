import 'package:flutter/material.dart';

/// A network image that never leaves a hole: a soft placeholder while it
/// loads and a gradient when the device is offline.
class DemoImage extends StatelessWidget {
  const DemoImage(this.url, {this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  static const _placeholder = Color(0xffe9edf3);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: _placeholder),
      errorBuilder: (context, error, stackTrace) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffcfd8e6), Color(0xff9fb0c8)],
          ),
        ),
        child: Center(
          child: Icon(Icons.landscape_rounded, color: Colors.white70, size: 36),
        ),
      ),
    );
  }
}
