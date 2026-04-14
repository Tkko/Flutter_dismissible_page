import 'dart:math';

import 'package:example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const accentColor = Color(0xff00d573);

void main() => runApp(const AppView());

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: accentColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
            chipTheme: const ChipThemeData(selectedColor: accentColor),
            sliderTheme: SliderThemeData(
              activeTrackColor: accentColor,
              activeTickMarkColor: accentColor,
              thumbColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: .2),
            ),
          ),
          home: const DismissiblePageDemo(),
        );

        final shortestSide = min(
          constraints.maxWidth.abs(),
          constraints.maxHeight.abs(),
        );

        if (shortestSide > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'Dismissible Examples',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 500,
                    height: min(1100, constraints.maxHeight.abs()),
                    margin: const EdgeInsets.all(20),
                    clipBehavior: Clip.antiAlias,
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(width: 15),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: app,
                  ),
                ),
              ],
            ),
          );
        }
        return app;
      },
    );
  }
}
