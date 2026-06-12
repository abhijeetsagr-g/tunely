import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/widget/album_art.dart';

class PlayerAlbumArt extends StatelessWidget {
  const PlayerAlbumArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (previous, current) =>
          (previous.currentItem != current.currentItem) ||
          (previous.isPlaying != current.isPlaying),
      builder: (context, state) {
        final tune = state.currentItem;
        final playScale = state.isPlaying ? 1.0 : 300 / 320;

        return SizedBox(
          height: 320,
          child: Align(
            child: AnimatedScale(
              scale: playScale,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final scale = Tween<double>(
                    begin: 0.85,
                    end: 1.0,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: scale, child: child),
                  );
                },
                child: AlbumArt(
                  key: ValueKey(tune?.songId),
                  id: tune?.songId,
                  type: ArtworkType.AUDIO,
                  size: const Size(320, 320),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
