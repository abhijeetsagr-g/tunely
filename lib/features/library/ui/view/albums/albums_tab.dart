import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/shared/widget/album_card.dart';

class AlbumsTab extends StatelessWidget {
  final List<AlbumModel> albums;
  final SortType sortType;
  final SortOrder sortOrder;

  const AlbumsTab({
    super.key,
    required this.albums,
    required this.sortType,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const Center(child: Text("No albums found."));

    final sorted = List<AlbumModel>.of(albums);
    switch (sortType) {
      case SortType.name:
        sorted.sort((a, b) => a.album.compareTo(b.album));
      case SortType.songCount:
        sorted.sort((a, b) => a.numOfSongs.compareTo(b.numOfSongs));
      default:
        break;
    }
    final sortedAlbums = sortOrder == SortOrder.descending
        ? sorted.reversed.toList()
        : sorted;

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  AlbumCard(album: sortedAlbums[index], width: 180),
              childCount: sortedAlbums.length,
            ),
          ),
        ),
      ],
    );
  }
}
