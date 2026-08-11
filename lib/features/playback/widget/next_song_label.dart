import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';

class NextSongLabel extends StatelessWidget {
  const NextSongLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (previous, current) =>
          previous.queue != current.queue ||
          previous.currentIndex != current.currentIndex,
      builder: (context, state) {
        final currentIndex = state.currentIndex ?? 0;
        final nextIndex = currentIndex + 1;
        final hasNext = nextIndex < state.queue.length;

        Tune? next = hasNext ? state.queue.elementAt(nextIndex) : null;
        String label = next != null ? next.title.toTitleCase() : "End Of Queue";

        if (!hasNext) {
          if (state.repeatMode == LoopMode.all && state.queue.isNotEmpty) {
            label = state.queue.first.title.toTitleCase();
          } else if (state.repeatMode == LoopMode.one) {
            label = state.currentItem?.title.toTitleCase() ?? "";
          }
        }

        return Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        );
      },
    );
  }
}
