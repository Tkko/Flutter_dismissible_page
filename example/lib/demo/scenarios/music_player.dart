import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:dismissible_page_example/demo/widgets/expanding_hero.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _artworkTag(DemoTrack track) => 'artwork-${track.title}';

/// A playlist with a mini player. Tapping the mini player opens "Now
/// playing" as a sheet that follows the finger, rounds its corners as it
/// goes, and leaves like a swipe when closed with the chevron.
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int _current = 0;
  bool _playing = true;

  DemoTrack get _track => demoTracks[_current];

  void _openPlayer() {
    context.pushTransparentRoute(
      NowPlayingPage(
        track: _track,
        playing: _playing,
        onPlayingChanged: (value) => setState(() => _playing = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const DismissibleBackButton(),
        title: Text(
          'Your library',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 110),
            itemCount: demoTracks.length,
            itemBuilder: (context, index) {
              final track = demoTracks[index];
              final selected = index == _current;
              return ListTile(
                onTap: () => setState(() {
                  _current = index;
                  _playing = true;
                }),
                leading: _Artwork(track: track, size: 52, radius: 12),
                title: Text(
                  track.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: selected ? track.top : null,
                  ),
                ),
                subtitle: Text(track.artist, style: GoogleFonts.poppins()),
                trailing: selected && _playing
                    ? Icon(Icons.graphic_eq_rounded, color: track.top)
                    : null,
              );
            },
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + MediaQuery.paddingOf(context).bottom,
            child: _MiniPlayer(
              track: _track,
              playing: _playing,
              onTap: _openPlayer,
              onToggle: () => setState(() => _playing = !_playing),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.track,
    required this.playing,
    required this.onTap,
    required this.onToggle,
  });

  final DemoTrack track;
  final bool playing;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: track.bottom,
      elevation: 8,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Artwork(
                track: track,
                size: 46,
                radius: 10,
                heroTag: _artworkTag(track),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      track.artist,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    required this.track,
    required this.playing,
    required this.onPlayingChanged,
    super.key,
  });

  final DemoTrack track;
  final bool playing;
  final ValueChanged<bool> onPlayingChanged;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  static const _length = Duration(minutes: 3, seconds: 24);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _length,
  );
  late bool _playing = widget.playing;

  @override
  void initState() {
    super.initState();
    _progress.value = 0.32;
    if (_playing) _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _playing = !_playing);
    widget.onPlayingChanged(_playing);
    _playing ? _progress.forward() : _progress.stop();
  }

  String _format(double fraction) {
    final seconds = (_length.inSeconds * fraction).round();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;

    return DismissibleDemo(
      // A sheet leaves downwards.
      direction: DismissiblePageDismissDirection.down,
      child: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [track.top, track.bottom],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Row(
                    children: [
                      // A Builder, so the context is below the DismissiblePage.
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => DismissiblePage.dismiss(context),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'NOW PLAYING',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  _Artwork(
                    track: track,
                    // Capped by height too, so the controls always fit.
                    size: min(
                      MediaQuery.sizeOf(context).width - 56,
                      MediaQuery.sizeOf(context).height * 0.34,
                    ),
                    radius: 28,
                    shadow: true,
                    heroTag: _artworkTag(track),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          track.artist,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _progress.value,
                            onChanged: (value) => _progress.value = value,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(_progress.value),
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '-${_format(1 - _progress.value)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.shuffle_rounded, color: Colors.white60),
                      const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      GestureDetector(
                        onTap: _toggle,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: track.bottom,
                            size: 40,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      const Icon(Icons.repeat_rounded, color: Colors.white60),
                    ],
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

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.track,
    required this.size,
    required this.radius,
    this.shadow = false,
    this.heroTag,
  });

  final DemoTrack track;
  final double size;
  final double radius;
  final bool shadow;

  /// When set, the artwork flies between the mini player and the sheet.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    // Without a Hero the artwork rounds itself; with one, the Hero rounds it,
    // so the corners can change as it flies.
    final face = SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: heroTag == null ? BorderRadius.circular(radius) : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [track.top, Color.lerp(track.top, track.bottom, 0.8)!],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Icon(
            track.icon,
            color: Colors.white70,
            size: constraints.biggest.shortestSide * 0.42,
          ),
        ),
      ),
    );

    final art = heroTag == null
        ? face
        : ExpandingHero(tag: heroTag!, radius: radius, child: face);

    if (!shadow) return art;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: art,
    );
  }
}
