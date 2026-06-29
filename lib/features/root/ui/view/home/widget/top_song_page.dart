import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class TopSongWidget extends StatefulWidget {
  const TopSongWidget({
    super.key,
    required this.tune,
    required this.queue,
    required this.index,
  });

  final Tune tune;
  final List<Tune> queue;
  final int index;

  @override
  State<TopSongWidget> createState() => _TopSongPageState();
}

class _TopSongPageState extends State<TopSongWidget> {
  @override
  Widget build(BuildContext context) {
    final playCount = context.read<StatsCubit>().playCount(widget.tune.path);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Rank + Album art
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AlbumArt(
              id: widget.tune.songId,
              type: ArtworkType.AUDIO,
              size: const Size(120, 120),
            ),
          ),
          const SizedBox(width: 14),

          // Info + actions
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tune.title.toTitleCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  formatArtistName(
                    context.read<ManagementCubit>().state.artistDelimiters,
                    widget.tune.artist,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 13,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$playCount plays',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<PlaybackBloc>().add(
                        PlayQueueEvent(widget.queue, startIndex: widget.index),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Play',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Add to playlist',
                      child: IconButton(
                        onPressed: () {
                          context.read<PlaybackBloc>().add(
                            PlayAfterThisEvent(widget.tune),
                          );
                        },
                        icon: Icon(
                          Icons.playlist_add,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer.withAlpha(150),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
