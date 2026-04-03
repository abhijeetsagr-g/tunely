import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/shared/widgets/album_art.dart';
import 'package:tunely/shared/widgets/song_tile.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.albumId});
  final int albumId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    final album = cubit.albumById(albumId);
    final tunes = cubit.tunesByAlbum(albumId);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.keyboard_arrow_down),
            ),
            title: Text(
              "${album?.artist?.replaceAll('/', ' • ').toTitleCase()}",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

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
                        id: albumId,
                        size: const Size(260, 260),
                        type: ArtworkType.ALBUM,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Album Title
                  Text(
                    album!.album.toTitleCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 24,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Artist & Info
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
            padding: const EdgeInsets.only(bottom: 24),

            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final tune = tunes[index];
                return SongTile(tune: tune, index: index, tunes: tunes);
              }, childCount: tunes.length),
            ),
          ),
        ],
      ),
    );
  }
}
