import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/queue/widget/queue_song_tile.dart';

class QueueWidget extends StatelessWidget {
  const QueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PlaybackBloc, PlaybackState>(
      builder: (context, state) {
        final tunes = state.queue;
        final index = state.currentIndex ?? 0;
        final nextIndex = index + 1;

        final hasNext = nextIndex < tunes.length;
        final upcoming = hasNext ? tunes.sublist(nextIndex + 1) : [];

        if (!hasNext) {
          return Center(
            child: Text('End of Queue', style: theme.textTheme.bodyMedium),
          );
        }

        final nextTile = QueueSongTile(
          index: nextIndex,
          tune: tunes[nextIndex],
        );

        if (upcoming.isEmpty) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _SectionLabel(label: 'Next Song'),
              nextTile,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Next Song'),
            nextTile,
            const SizedBox(height: 8),
            _SectionLabel(label: 'Upcoming'),
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.only(bottom: 24),
                onReorderItem: (oldIndex, newIndex) {
                  final offset = nextIndex + 1;
                  context.read<PlaybackBloc>().add(
                    ChangeQueueOrder(
                      oldIndex: offset + oldIndex,
                      newIndex: offset + newIndex,
                    ),
                  );
                },
                children: upcoming
                    .mapIndexed(
                      (i, t) => QueueSongTile(
                        key: ValueKey(t.path),
                        tune: tunes[nextIndex + 1 + i],
                        index: nextIndex + 1 + i,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(40),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
