import 'dart:math';
import 'dart:ui';
import 'package:dismissible_page_example/demo/models/demo_settings.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

const accentColor = Color(0xff00d573);

void main() => runApp(const AppView());

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _model = DismissiblePageModel();

  @override
  Widget build(BuildContext context) {
    return DemoSettings(model: _model, child: _buildApp());
  }

  Widget _buildApp() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
          home: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: const DismissiblePageDemo(),
          ),
        );

        final shortestSide =
            min(constraints.maxWidth.abs(), constraints.maxHeight.abs());

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
                      border: Border.all(color: Colors.black, width: 15),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 15),
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
