import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/demo.dart';
import 'package:dismissible_page_example/demo/models/models.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _labBackground = Color(0xff111318);
const _labSurface = Color(0xff1b1e26);

/// Entry card on the demo page.
class MotionLabCard extends StatelessWidget {
  const MotionLabCard({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        color: _labBackground,
        child: InkWell(
          onTap: () => context.pushTransparentRoute(
            MotionLabPage(pageModel: pageModel),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _labBackground,
                  accentColor.withValues(alpha: 0.35),
                ],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: accentColor, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motion Lab',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tune the spring live, then drag the page to feel it',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dismissible page that edits its own motion while you use it: change a
/// number, drag the page down, let go, and feel the difference.
class MotionLabPage extends StatefulWidget {
  const MotionLabPage({required this.pageModel, super.key});

  final DismissiblePageModel pageModel;

  @override
  State<MotionLabPage> createState() => _MotionLabPageState();
}

class _MotionLabPageState extends State<MotionLabPage> {
  DismissiblePageModel get model => widget.pageModel;

  static const _presets = <String, (double, double)>{
    'Smooth': (900, 1.0),
    'Snappy': (1500, 1.0),
    'Bouncy': (900, 0.6),
    'Jelly': (450, 0.35),
    'Heavy': (300, 1.0),
  };

  void _update(VoidCallback change) => setState(change);

  void _applyPreset((double, double) preset) => _update(() {
        model.reboundKind = ReboundKind.custom;
        model.stiffness = preset.$1;
        model.dampingRatio = preset.$2;
      });

  bool _isPreset((double, double) preset) =>
      model.reboundKind != ReboundKind.curve &&
      model.stiffness == preset.$1 &&
      model.dampingRatio == preset.$2;

  String get _spec {
    final rebound = model.reboundKind == ReboundKind.curve
        ? 'DismissiblePageRebound.curve()'
        : 'DismissiblePageRebound.spring(\n'
            '        stiffness: ${model.stiffness.round()},\n'
            '        dampingRatio: ${model.dampingRatio.toStringAsFixed(2)},\n'
            '      )';
    return 'DismissiblePage(\n'
        '  dismissThresholds: {\n'
        '    for (final side in DismissiblePageSide.values)\n'
        '      side: ${model.dismissThreshold.toStringAsFixed(2)},\n'
        '  },\n'
        '  motion: DismissiblePageMotion(\n'
        '    rebound: $rebound,\n'
        '    continueOnDismiss: ${model.continueOnDismiss},\n'
        '    thresholdHaptics: ${model.thresholdHaptics},\n'
        '    flingVelocity: ${model.flingVelocity.round()},\n'
        '    flingMinDistance: ${model.flingMinDistance.toStringAsFixed(2)},\n'
        '  ),\n'
        '  // ...\n'
        ')';
  }

  @override
  Widget build(BuildContext context) {
    final isSpring = model.reboundKind != ReboundKind.curve;
    final metrics = _SpringMetrics(model.stiffness, model.dampingRatio);

    return DismissibleDemo(
      pageModel: model,
      child: Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _labBackground,
        ),
        child: Scaffold(
          backgroundColor: _labBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Motion Lab',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // A Builder, so the context is below the DismissiblePage.
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => DismissiblePage.dismiss(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Drag this page down and let go. It rebounds with the '
                    'spring you are tuning below.',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Panel(
                    child: isSpring
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 150,
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: _SpringPainter(
                                    stiffness: model.stiffness,
                                    dampingRatio: model.dampingRatio,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _Stat('Settles', '${metrics.settleMs} ms'),
                                  _Stat(
                                    'Overshoot',
                                    '${metrics.overshoot.toStringAsFixed(0)}%',
                                  ),
                                  _Stat('Feels', metrics.feel),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            'A fixed easeOutCubic curve ignores release '
                            'velocity. Pick a spring to see its response.',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in _presets.entries)
                        AppChip(
                          onSelected: () => _applyPreset(entry.value),
                          isSelected: _isPreset(entry.value),
                          title: entry.key,
                        ),
                      AppChip(
                        onSelected: () => _update(
                          () => model.reboundKind = ReboundKind.curve,
                        ),
                        isSelected: !isSpring,
                        title: 'Old curve',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isSpring) ...[
                    _LabSlider(
                      label: 'Stiffness',
                      value: model.stiffness,
                      min: 150,
                      max: 2000,
                      format: (v) => v.round().toString(),
                      onChanged: (v) => _update(() {
                        model.reboundKind = ReboundKind.custom;
                        model.stiffness = v;
                      }),
                    ),
                    _LabSlider(
                      label: 'Damping ratio',
                      value: model.dampingRatio,
                      min: 0.25,
                      max: 1.5,
                      format: (v) => v.toStringAsFixed(2),
                      onChanged: (v) => _update(() {
                        model.reboundKind = ReboundKind.custom;
                        model.dampingRatio = v;
                      }),
                    ),
                  ],
                  _LabSlider(
                    label: 'Dismiss distance',
                    value: model.dismissThreshold,
                    min: 0.08,
                    max: 0.5,
                    format: (v) => '${(v * 100).round()}% of page',
                    onChanged: (v) => _update(
                      () => model.setDismissThreshold(v),
                    ),
                  ),
                  _LabSlider(
                    label: 'Fling speed',
                    value: model.flingVelocity,
                    min: 300,
                    max: 3000,
                    format: (v) => '${v.round()} px/s',
                    onChanged: (v) => _update(() => model.flingVelocity = v),
                  ),
                  _LabSlider(
                    label: 'Fling min distance',
                    value: model.flingMinDistance,
                    min: 0,
                    max: 0.3,
                    format: (v) => '${(v * 100).round()}% of page',
                    onChanged: (v) => _update(
                      () => model.flingMinDistance = v,
                    ),
                  ),
                  _LabSwitch(
                    title: 'Keep moving on dismiss',
                    value: model.continueOnDismiss,
                    onChanged: (v) => _update(
                      () => model.continueOnDismiss = v,
                    ),
                  ),
                  _LabSwitch(
                    title: 'Haptic tick at the threshold',
                    value: model.thresholdHaptics,
                    onChanged: (v) => _update(
                      () => model.thresholdHaptics = v,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) => FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(ClipboardData(text: _spec));
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Copied as Dart, ready to paste'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.code_rounded),
                      label: Text(
                        'Copy as code',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _labSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabSlider extends StatelessWidget {
  const _LabSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
            ),
            Text(
              format(value),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LabSwitch extends StatelessWidget {
  const _LabSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: accentColor,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}

/// The numbers a designer reads off a spring.
class _SpringMetrics {
  factory _SpringMetrics(double stiffness, double dampingRatio) {
    final simulation = _simulation(stiffness, dampingRatio);
    var peak = 0.0;
    var settleMs = 0;
    for (var ms = 0; ms <= 2000; ms += 4) {
      final x = simulation.x(ms / 1000);
      peak = max(peak, x);
      if ((x - 1).abs() > 0.01) settleMs = ms + 4;
    }
    final overshoot = max(0.0, peak - 1) * 100;
    final feel = overshoot > 25
        ? 'Jelly'
        : overshoot > 6
            ? 'Bouncy'
            : settleMs < 230
                ? 'Snappy'
                : settleMs > 450
                    ? 'Heavy'
                    : 'Smooth';
    return _SpringMetrics._(settleMs, overshoot, feel);
  }

  const _SpringMetrics._(this.settleMs, this.overshoot, this.feel);

  final int settleMs;
  final double overshoot;
  final String feel;
}

SpringSimulation _simulation(double stiffness, double dampingRatio) {
  return SpringSimulation(
    SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: stiffness,
      ratio: dampingRatio,
    ),
    0,
    1,
    0,
  );
}

/// Plots a spring's response to a step, from 0 to 1, with the settle point.
class _SpringPainter extends CustomPainter {
  const _SpringPainter({required this.stiffness, required this.dampingRatio});

  final double stiffness;
  final double dampingRatio;

  static const _span = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final simulation = _simulation(stiffness, dampingRatio);
    const samples = 160;
    final values = [
      for (var i = 0; i <= samples; i++) simulation.x(_span * i / samples),
    ];
    final top = max(1.3, values.reduce(max) * 1.08);
    double dy(double v) => size.height - (v / top) * size.height;
    double dx(int i) => size.width * i / samples;

    final grid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    // The target the spring is heading for.
    final targetY = dy(1);
    final dash = Paint()
      ..color = accentColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, targetY), Offset(x + 5, targetY), dash);
    }

    final path = Path()..moveTo(0, dy(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(dx(i), dy(values[i]));
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.28),
            accentColor.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Where it stops moving visibly.
    var settle = 0;
    for (var i = 0; i <= samples; i++) {
      if ((values[i] - 1).abs() > 0.01) settle = i;
    }
    if (settle < samples) {
      final x = dx(settle + 1);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 1,
      );
      canvas.drawCircle(Offset(x, targetY), 5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_SpringPainter oldDelegate) =>
      stiffness != oldDelegate.stiffness ||
      dampingRatio != oldDelegate.dampingRatio;
}
