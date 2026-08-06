import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/animated_gradient_background.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

class PlayerGradientBackground extends StatefulWidget {
  const PlayerGradientBackground({super.key});

  @override
  State<PlayerGradientBackground> createState() =>
      _PlayerGradientBackgroundState();
}

class _PlayerGradientBackgroundState extends State<PlayerGradientBackground> {
  Color? _color;
  int? _lastSongId; // guard it up

  @override
  void initState() {
    super.initState();
    // Trigger color extraction immediately if a song is already playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final songId = context.read<PlaybackBloc>().state.currentItem?.songId;
      _updateColor(songId);
    });
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
    setState(() => _color = color);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaybackBloc, PlaybackState>(
      listenWhen: (prev, curr) =>
          prev.currentItem?.songId != curr.currentItem?.songId,
      listener: (context, state) => _updateColor(state.currentItem?.songId),
      child: AnimatedGradientBackground(color: _color),
    );
  }
}
