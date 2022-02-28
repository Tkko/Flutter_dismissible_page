import 'dart:ui';
import 'package:example/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

const accentColor = Color(0xff00d573);

void main() => runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: accentColor,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(color: Colors.white),
          chipTheme: ChipThemeData(selectedColor: accentColor),
          sliderTheme: SliderThemeData(
            activeTrackColor: accentColor,
            activeTickMarkColor: accentColor,
            thumbColor: accentColor,
            inactiveTrackColor: accentColor.withOpacity(.2),
          ),
        ),
        home: ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: DismissiblePageDemo(),
        ),
      ),
    );
