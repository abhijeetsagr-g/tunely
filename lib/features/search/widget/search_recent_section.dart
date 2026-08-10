import 'package:flutter/material.dart';
import 'package:tunely/features/search/model/recent_item.dart';
import 'package:tunely/shared/widget/album_tile.dart';
import 'package:tunely/shared/widget/artist_card.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({
    super.key,
    required this.items,
    required this.onTapItem,
    required this.onClearAll,
  });

  final List<RecentItem> items;
  final ValueChanged<RecentItem> onTapItem;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, i) =>
              _RecentItemTile(item: items[i], onTap: () => onTapItem(items[i])),
        ),
      ],
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  const _RecentItemTile({required this.item, required this.onTap});

  final RecentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      RecentSongItem s => SongTile(tunes: [s.tune], index: 0, onTap: onTap),
      RecentAlbumItem a => AlbumTile(album: a.album, onTap: onTap),
      RecentArtistItem a => ArtistCard(artist: a.artist, onTap: onTap),
    };
  }
}
