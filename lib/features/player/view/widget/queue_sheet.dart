import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/player/view/widget/queue_list_tile.dart';
import 'package:tunely/features/player/view/widget/up_next_tile.dart';
import 'package:tunely/shared/model/tune.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      builder: (context, state) {
        final queue = state.queue;
        final currentIndex = state.currentIndex;
        final upNext = (currentIndex >= 0 && currentIndex + 1 < queue.length)
            ? queue[currentIndex + 1]
            : null;

        final remaining = (currentIndex >= 0 && currentIndex + 2 < queue.length)
            ? queue.sublist(currentIndex + 2)
            : <Tune>[];
        final remainingStartIndex = currentIndex + 2;

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  // ── Handle + Header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withAlpha(40),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text(
                                'Queue',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${queue.length} songs',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(120),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // ── Up Next Card ──────────────────────────────────────────
                  if (upNext != null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UP NEXT',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            UpNextTile(
                              tune: upNext,
                              onTap: () {
                                context.read<PlaybackBloc>().add(PlayNext());
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── "In Queue" label ──────────────────────────────────────
                  if (remaining.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'IN QUEUE',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(120),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                  if (remaining.isNotEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ── Remaining queue list ──────────────────────────────────
                  SliverList.builder(
                    itemCount: remaining.length,
                    itemBuilder: (context, i) {
                      final tune = remaining[i];
                      final queueIndex = remainingStartIndex + i;
                      return QueueListTile(
                        tune: tune,
                        position: queueIndex,
                        onTap: () {
                          context.read<PlaybackBloc>().add(
                            SkipToQueueItem(queueIndex),
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),

                  // ── Empty state ───────────────────────────────────────────
                  if (upNext == null && remaining.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.queue_music_rounded,
                              size: 48,
                              color: colorScheme.onSurface.withAlpha(60),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nothing else in queue',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
