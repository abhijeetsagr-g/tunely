import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class TopSongPage extends StatefulWidget {
  const TopSongPage({
    super.key,
    required this.tune,
    required this.queue,
    required this.index,
  });

  final Tune tune;
  final List<Tune> queue;
  final int index;

  @override
  State<TopSongPage> createState() => _TopSongPageState();
}

class _TopSongPageState extends State<TopSongPage> {
  Color? _extractedColor;

  @override
  void initState() {
    super.initState();
    _extract();
  }

  @override
  void didUpdateWidget(TopSongPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tune.path != widget.tune.path) _extract();
  }

  Future<void> _extract() async {
    final color = await context.read<CustomizationCubit>().extractColors(
      widget.tune.songId,
    );
    if (mounted) setState(() => _extractedColor = color);
  }

  List<Color> get _gradientColors {
    final base = _extractedColor;
    if (base == null) {
      return [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer,
      ];
    }
    return [base.withAlpha(200), base.withAlpha(100)];
  }

  @override
  Widget build(BuildContext context) {
    final playCount = context.read<StatsCubit>().playCount(widget.tune.path);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Rank + Album art
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AlbumArt(
              id: widget.tune.albumId ?? 0,
              size: const Size(120, 120),
              type: ArtworkType.ALBUM,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withAlpha(60),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withAlpha(50),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$playCount plays',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withAlpha(50),
                      ),
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
                          color:
                              _extractedColor ??
                              Theme.of(context).colorScheme.primary,
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
                        onPressed: () {},
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
