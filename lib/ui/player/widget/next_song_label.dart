import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart'
    hide RepeatMode;

class NextSongLabel extends StatelessWidget {
  const NextSongLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.nextSong != curr.nextSong || prev.repeatMode != curr.repeatMode,
      builder: (context, state) {
        final next = state.repeatMode == .one
            ? state.currentSong
            : state.hasNext
            ? state.nextSong
            : null;

        return Text(
          next != null ? next.title.toTitleCase() : "End Is Here",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        );
      },
    );
  }
}
