import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_card.dart';

class ArtistsTab extends StatelessWidget {
  final List<Artist> artists;
  final SortType sortType;
  final SortOrder sortOrder;

  const ArtistsTab({
    super.key,
    required this.artists,
    required this.sortType,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const Center(child: Text("No artists found."));

    final sorted = List<Artist>.of(artists);
    switch (sortType) {
      case SortType.name:
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
      case SortType.songCount:
        sorted.sort((a, b) => a.tunes.length.compareTo(b.tunes.length));
      default:
        break;
    }
    final sortedArtists = sortOrder == SortOrder.descending
        ? sorted.reversed.toList()
        : sorted;

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return ArtistCard(artist: sortedArtists[index]);
            }, childCount: sortedArtists.length),
          ),
        ),
      ],
    );
  }
}
