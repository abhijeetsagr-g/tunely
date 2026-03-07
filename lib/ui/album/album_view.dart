import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/data/model/tune.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.album, required this.tunes});
  final AlbumModel album;
  final List<Tune> tunes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                album.album,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: AlbumArt(
                id: album.id,
                size: Size(250, 250),
                type: .ALBUM,
              ),
            ),
          ),

          /// Album metadata
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.album,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    album.artist ?? "Unknown Artist",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${tunes.length} songs",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          /// Song list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tune = tunes[index];
              return SongTile(tune: tune, index: index, tunes: tunes);
            }, childCount: tunes.length),
          ),
        ],
      ),
    );
  }
}
