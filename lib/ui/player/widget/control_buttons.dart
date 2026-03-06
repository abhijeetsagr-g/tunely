import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.isPlaying != curr.isPlaying ||
          prev.hasNext != curr.hasNext ||
          prev.hasPrev != curr.hasPrev ||
          prev.isShuffleMode != curr.isShuffleMode ||
          prev.repeatMode != curr.repeatMode,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            IconButton(
              onPressed: () =>
                  context.read<PlaybackBloc>().add(ToggleShuffle()),
              icon: Icon(
                Icons.shuffle,
                color: state.isShuffleMode ? Colors.purple : null,
              ),
            ),

            /// Previous
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.skip_previous),
              onPressed: state.hasPrev
                  ? () => context.read<PlaybackBloc>().add(PlayPrev())
                  : null,
            ),

            const SizedBox(width: 20),

            /// Play / Pause
            IconButton(
              iconSize: 70,
              icon: Icon(
                state.isPlaying ? Icons.pause_circle : Icons.play_circle,
              ),
              onPressed: () {
                if (state.isPlaying) {
                  context.read<PlaybackBloc>().add(Pause());
                } else {
                  context.read<PlaybackBloc>().add(Play());
                }
              },
            ),

            const SizedBox(width: 20),

            /// Next
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.skip_next),
              onPressed: state.hasNext
                  ? () => context.read<PlaybackBloc>().add(PlayNext())
                  : null,
            ),

            // Repeat Button
            IconButton(
              icon: Icon(switch (state.repeatMode) {
                RepeatMode.none => Icons.repeat,

                RepeatMode.one => Icons.repeat_one_on,

                RepeatMode.all => Icons.repeat_on,
              }),
              onPressed: () => context.read<PlaybackBloc>().add(CycleRepeat()),
            ),
          ],
        );
      },
    );
  }
}
