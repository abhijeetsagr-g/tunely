import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.album, required this.tunes});
  final AlbumModel album;
  final List<Tune> tunes;

  @override
  Widget build(BuildContext context) {
    final sortedTunes = [...tunes]
      ..sort((a, b) {
        if (a.trackIndex == null) return 1;
        if (b.trackIndex == null) return -1;
        return a.trackIndex!.compareTo(b.trackIndex!);
      });
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(floating: true, pinned: false),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center the art for a focused look
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AlbumArt(
                        id: album.id,
                        size: const Size(260, 260),
                        type: ArtworkType.ALBUM,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Album Title
                  Text(
                    album.album.toTitleCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 24,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Artist & Info
                  Text(
                    "${album.artist?.toUpperCase() ?? 'Unknown'} • ${album.numOfSongs} tracks",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<PlaybackBloc>().add(
                              PlaySong(index: 0, tune: tunes),
                            );

                            Navigator.pushNamed(context, AppRoutes.player);
                          },

                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text("Play"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            final bloc = context.read<PlaybackBloc>();
                            bloc.add(ShuffleAll(tunes: tunes));

                            Navigator.pushNamed(context, AppRoutes.player);
                          },
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text("Play Shuffle"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // List Section
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),

            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final tune = sortedTunes[index];
                return SongTile(tune: tune, index: index, tunes: sortedTunes);
              }, childCount: sortedTunes.length),
            ),
          ),
        ],
      ),
    );
  }
}
