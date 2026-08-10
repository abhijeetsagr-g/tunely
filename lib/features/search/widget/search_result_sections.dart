import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/search/widget/search_section_header.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_card.dart';
import 'package:tunely/shared/widget/artist_card.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SearchSongsSection extends StatelessWidget {
  const SearchSongsSection({
    super.key,
    required this.tunes,
    required this.onTap,
  });

  final List<Tune> tunes;
  final ValueChanged<Tune> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SearchSectionHeader(label: 'Songs', count: tunes.length),
        SliverList.builder(
          itemCount: tunes.length,
          itemBuilder: (context, i) =>
              SongTile(index: i, tunes: tunes, onTap: () => onTap(tunes[i])),
        ),
      ],
    );
  }
}

class SearchAlbumsSection extends StatelessWidget {
  const SearchAlbumsSection({
    super.key,
    required this.albums,
    required this.onTap,
  });

  final List<AlbumModel> albums;
  final ValueChanged<AlbumModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SearchSectionHeader(label: 'Albums', count: albums.length),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: albums.length,
            itemBuilder: (context, i) =>
                AlbumCard(album: albums[i], onTap: () => onTap(albums[i])),
          ),
        ),
      ],
    );
  }
}

class SearchArtistsSection extends StatelessWidget {
  const SearchArtistsSection({
    super.key,
    required this.artists,
    required this.onTap,
  });

  final List<Artist> artists;
  final ValueChanged<Artist> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SearchSectionHeader(label: 'Artists', count: artists.length),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in artists)
                  ArtistCard(artist: a, onTap: () => onTap(a)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
