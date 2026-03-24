import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/common/album_art.dart';
import 'package:tunely/ui/common/artist_image.dart';
import 'package:tunely/ui/common/song_tile.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key, required this.artistId});
  final int artistId;

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late final Map<String, List<Tune>> _grouped;
  late final Set<String> _collapsed;

  Map<String, List<Tune>> _groupByAlbum(List<Tune> tunes) {
    final map = <String, List<Tune>>{};
    for (final tune in tunes) {
      final album = tune.album;
      map.putIfAbsent(album, () => []).add(tune);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    final tunes = context.read<LibraryCubit>().tunesByArtist(widget.artistId);
    _grouped = _groupByAlbum(tunes);
    _collapsed = {};
  }

  void _toggleAlbum(String album) {
    setState(() {
      if (_collapsed.contains(album)) {
        _collapsed.remove(album);
      } else {
        _collapsed.add(album);
      }
    });
  }

  List<Object> get _items {
    final items = <Object>[];
    for (final entry in _grouped.entries) {
      items.add(entry.key);
      if (!_collapsed.contains(entry.key)) {
        items.addAll(entry.value);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    final artist = cubit.artistById(widget.artistId);
    final tunes = cubit.tunesByArtist(widget.artistId);
    final theme = Theme.of(context);
    final items = _items;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ArtistImage(
                      artistName: artist?.artist ?? '',
                      artistId: widget.artistId,
                      size: 260,
                      borderRadius: 130,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    artist?.artist.toTitleCase() ?? 'Unknown Artist',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 24,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${artist?.numberOfAlbums ?? 0} albums • ${artist?.numberOfTracks ?? 0} tracks",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.read<PlaybackBloc>().add(
                            PlaySong(index: 0, tune: tunes),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text("Play"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => context.read<PlaybackBloc>().add(
                            ShuffleAll(tunes: tunes),
                          ),
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

          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];

                if (item is String) {
                  final albumId = tunes
                      .firstWhere((t) => (t.album) == item)
                      .albumId;
                  final isCollapsed = _collapsed.contains(item);

                  return InkWell(
                    onTap: () => _toggleAlbum(item),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AlbumArt(
                              id: albumId ?? 0,
                              size: const Size(60, 60),
                              type: ArtworkType.ALBUM,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.toTitleCase(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isCollapsed ? -0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tune = item as Tune;
                final tunesInAlbum = _grouped[tune.album]!;
                final indexInAlbum = tunesInAlbum.indexOf(tune);
                return SongTile(
                  tune: tune,
                  index: indexInAlbum,
                  tunes: tunesInAlbum,
                );
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }
}
