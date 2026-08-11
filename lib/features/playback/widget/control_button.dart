import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    double iconSize = 22,
    bool isActive = false,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withAlpha(50)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        iconSize: iconSize,
        icon: Icon(
          icon,
          color: isDisabled
              ? Theme.of(context).iconTheme.color?.withAlpha(30)
              : isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).iconTheme.color,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.isPlaying != curr.isPlaying ||
          prev.queue != curr.queue ||
          prev.shuffleEnabled != curr.shuffleEnabled ||
          prev.repeatMode != curr.repeatMode,
      builder: (context, state) {
        final bloc = context.read<PlaybackBloc>();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            _buildIconButton(
              context: context,
              icon: Icons.shuffle,
              onPressed: () => bloc.add(SetShuffleEvent()),
              isActive: state.shuffleEnabled,
            ),

            /// Previous
            _buildIconButton(
              context: context,
              icon: Icons.skip_previous,
              iconSize: 40,
              onPressed: () => bloc.add(SkipToPreviousEvent()),
            ),

            /// Play / Pause
            _buildIconButton(
              iconSize: 60,
              context: context,
              icon: state.isPlaying ? Icons.pause_circle : Icons.play_circle,
              onPressed: () =>
                  bloc.add(state.isPlaying ? PauseEvent() : PlayEvent()),
            ),

            /// Next
            _buildIconButton(
              context: context,
              icon: Icons.skip_next,
              iconSize: 40,
              onPressed: () => bloc.add(SkipToNextEvent()),
            ),

            // Repeat Button
            _buildIconButton(
              context: context,
              icon: switch (state.repeatMode) {
                LoopMode.off => Icons.repeat_sharp,
                LoopMode.one => Icons.repeat_one_sharp,
                LoopMode.all => Icons.repeat_on,
              },
              isActive: state.repeatMode != LoopMode.off,
              onPressed: () => bloc.add(SetRepeatEvent()),
            ),
          ],
        );
      },
    );
  }
}
