import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SongsTab extends StatelessWidget {
  final List<Tune> tunes;
  final SortType sortType;
  final SortOrder sortOrder;

  const SongsTab({
    super.key,
    required this.tunes,
    required this.sortType,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (tunes.isEmpty) {
      return const Center(child: Text("No songs found."));
    }

    final sorted = sortTunes(tunes, sortType, sortOrder);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SongTile(tunes: sorted, index: index),
              childCount: sorted.length,
            ),
          ),
        ),
      ],
    );
  }
}
