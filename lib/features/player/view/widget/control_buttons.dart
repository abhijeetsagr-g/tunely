import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

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
            ? Theme.of(context).primaryColor.withAlpha(15)
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
          prev.hasNext != curr.hasNext ||
          prev.hasPrev != curr.hasPrev ||
          prev.isShuffleMode != curr.isShuffleMode ||
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
              onPressed: () => bloc.add(ToggleShuffle()),
              isActive: state.isShuffleMode,
            ),

            /// Previous
            _buildIconButton(
              context: context,
              icon: Icons.skip_previous,
              iconSize: 40,
              isDisabled: !state.hasPrev,
              onPressed: state.hasPrev ? () => bloc.add(PlayPrev()) : null,
            ),

            /// Play / Pause
            _buildIconButton(
              iconSize: 60,
              context: context,
              icon: state.isPlaying ? Icons.pause_circle : Icons.play_circle,
              onPressed: () => bloc.add(state.isPlaying ? Pause() : Play()),
            ),

            /// Next
            _buildIconButton(
              context: context,
              icon: Icons.skip_next,
              iconSize: 40,
              isDisabled: !state.hasNext,
              onPressed: state.hasNext ? () => bloc.add(PlayNext()) : null,
            ),

            // Repeat Button
            _buildIconButton(
              context: context,
              icon: switch (state.repeatMode) {
                RepeatMode.none => Icons.repeat_sharp,
                RepeatMode.one => Icons.repeat_one_sharp,
                RepeatMode.all => Icons.repeat_on,
              },
              isActive: state.repeatMode != RepeatMode.none,
              onPressed: () => bloc.add(CycleRepeat()),
            ),
          ],
        );
      },
    );
  }
}
