import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart' hide RepeatMode;
import 'package:tunely/features/player/view/widget/queue_sheet.dart';

class NextSongLabel extends StatelessWidget {
  const NextSongLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.currentSong != curr.currentSong ||
          prev.repeatMode != curr.repeatMode ||
          prev.isShuffleMode != curr.isShuffleMode ||
          prev.nextSong != curr.nextSong,
      builder: (context, state) {
        final next = state.repeatMode == .one
            ? state.currentSong
            : state.hasNext
            ? state.nextSong
            : null;

        return GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: context.read<PlaybackBloc>(),
              child: const QueueSheet(),
            ),
          ),
          child: Text(
            next != null ? next.title.toTitleCase() : "End Is Here",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        );
      },
    );
  }
}
