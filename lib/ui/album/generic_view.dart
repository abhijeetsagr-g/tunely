import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/query/query_state.dart';

class GenericView extends StatefulWidget {
  const GenericView({super.key, required this.args});
  final GenericViewArgs args;

  @override
  State<GenericView> createState() => _GenericViewState();
}

class _GenericViewState extends State<GenericView> {
  @override
  void initState() {
    super.initState();

    final type = switch (widget.args.type) {
      FilterType.album => AudiosFromType.ALBUM_ID,
      FilterType.playlist => AudiosFromType.PLAYLIST,
      FilterType.genres => AudiosFromType.GENRE_ID,
      FilterType.artists => AudiosFromType.ARTIST_ID,
    };

    context.read<QueryCubit>().getFilteredSongs(type, widget.args.id);
  }

  ArtworkType get _artworkType => switch (widget.args.type) {
    FilterType.album => ArtworkType.ALBUM,
    FilterType.playlist => ArtworkType.PLAYLIST,
    FilterType.genres => ArtworkType.GENRE,
    FilterType.artists => ArtworkType.ARTIST,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<QueryCubit, QueryState>(
        buildWhen: (prev, curr) =>
            prev.filteredSongs != curr.filteredSongs ||
            prev.isLoading != curr.isLoading,
        builder: (context, state) {
          final tunes = state.filteredSongs
              .map((s) => Tune.fromSongModel(s))
              .toList();

          return CustomScrollView(
            slivers: [
              const SliverAppBar(floating: true),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AlbumArt(
                            id: widget.args.id,
                            size: const Size(260, 260),
                            type: _artworkType,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        widget.args.name.toTitleCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        "${tunes.length} tracks",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (tunes.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  context.read<PlaybackBloc>().add(
                                    PlaySong(index: 0, tune: tunes),
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.player,
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
                                  context.read<PlaybackBloc>().add(
                                    ShuffleAll(tunes: tunes),
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.player,
                                  );
                                },
                                icon: const Icon(Icons.shuffle_rounded),
                                label: const Text("Shuffle"),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              if (state.isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => SongTile(
                        tune: tunes[index],
                        index: index,
                        tunes: tunes,
                      ),
                      childCount: tunes.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
