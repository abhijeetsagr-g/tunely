import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

class PlayerGradientBackground extends StatefulWidget {
  const PlayerGradientBackground({super.key});

  @override
  State<PlayerGradientBackground> createState() =>
      _PlayerGradientBackgroundState();
}

class _PlayerGradientBackgroundState extends State<PlayerGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  // animates from prev to new
  Color _currentColor = Colors.transparent;
  Color _previousColor = Colors.transparent;
  int? _lastSongId; // graud it up

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic, // smoother curve
    );

    // Seed with surface color so there's no transparent flash on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surface = Theme.of(context).colorScheme.surface;
      _previousColor = surface;
      _currentColor = surface;

      // Trigger color extraction immediately if a song is already playing
      final songId = context.read<PlaybackBloc>().state.currentItem?.songId;
      _updateColor(songId);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _updateColor(int? songId) async {
    if (songId == null || songId == _lastSongId) return;
    _lastSongId = songId;

    final brightness = Theme.of(context).brightness;
    final color = await context.read<CustomizationCubit>().extractColors(
      songId,
      brightness: brightness,
    );

    if (color == null || !mounted) return;

    _previousColor =
        Color.lerp(_previousColor, _currentColor, _animation.value) ??
        _currentColor;
    _currentColor = color;
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaybackBloc, PlaybackState>(
      listenWhen: (prev, curr) =>
          prev.currentItem?.songId != curr.currentItem?.songId,
      listener: (context, state) => _updateColor(state.currentItem?.songId),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final blended =
              Color.lerp(_previousColor, _currentColor, _animation.value) ??
              _currentColor;

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surface = Theme.of(context).colorScheme.surface;

          // Derive a softer mid-tone for smoother falloff
          final midColor = Color.lerp(blended, surface, 0.45) ?? surface;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
                colors: [
                  blended.withAlpha(isDark ? 72 : 48), // top bloom
                  blended.withAlpha(isDark ? 45 : 28), // upper fade
                  midColor.withAlpha(isDark ? 20 : 12), // mid feather
                  surface.withAlpha(isDark ? 6 : 4), // near-surface
                  surface, // full surface
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
