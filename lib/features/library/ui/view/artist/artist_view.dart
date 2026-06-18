import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/artist_avater.dart';
import 'package:tunely/shared/widget/song_action_row.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key, required this.artist});
  final Artist artist;

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  late final Set<int> _expandedAlbums;

  @override
  void initState() {
    super.initState();
    _expandedAlbums = widget.artist.tunes.map((t) => t.albumId ?? 0).toSet();
  }

  Map<int, _AlbumTunes> _groupByAlbum(List<Tune> tunes) {
    final map = <int, _AlbumTunes>{};
    for (final tune in tunes) {
      final id = tune.albumId ?? 0;
      map.putIfAbsent(id, () => _AlbumTunes(album: tune.album, tunes: []));
      map[id]!.tunes.add(tune);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByAlbum(widget.artist.tunes);
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => grouped[a]!.album.compareTo(grouped[b]!.album));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtistAvatar(size: Size(150, 150), artist: widget.artist),
                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          widget.artist.artist.toTitleCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                fontSize: 20,
                              ),
                        ),

                        Text(
                          "${widget.artist.tunes.length} Tunes",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SongActionRowSliver(tunes: widget.artist.tunes),

          for (final albumId in sortedKeys)
            ..._buildAlbumSection(context, albumId, grouped[albumId]!),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  List<Widget> _buildAlbumSection(
    BuildContext context,
    int albumId,
    _AlbumTunes group,
  ) {
    final isExpanded = _expandedAlbums.contains(albumId);

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedAlbums.remove(albumId);
                } else {
                  _expandedAlbums.add(albumId);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  AlbumArt(
                    size: const Size(40, 40),
                    id: albumId == 0 ? null : albumId,
                    type: ArtworkType.ALBUM,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.album.toTitleCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "${group.tunes.length}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (isExpanded) TuneSliverList(tunes: group.tunes),
    ];
  }
}

class _AlbumTunes {
  final String album;
  final List<Tune> tunes;
  const _AlbumTunes({required this.album, required this.tunes});
}
