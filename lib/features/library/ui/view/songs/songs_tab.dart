import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/features/library/ui/view/songs/song_sort_bar.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SongsTab extends StatefulWidget {
  final List<Tune> tunes;
  const SongsTab({super.key, required this.tunes});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  SortType _sortType = SortType.name;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  Widget build(BuildContext context) {
    if (widget.tunes.isEmpty) {
      return const Center(child: Text("No songs found."));
    }

    final sorted = sortTunes(widget.tunes, _sortType, _sortOrder);

    return ListView.builder(
      itemCount: sorted.length + 1,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        if (index == 0) {
          return SongSortBar(
            sortType: _sortType,
            sortOrder: _sortOrder,
            onSortTypeChanged: (type) => setState(() => _sortType = type),
            onSortOrderToggled: () => setState(() {
              _sortOrder = _sortOrder == SortOrder.ascending
                  ? SortOrder.descending
                  : SortOrder.ascending;
            }),
          );
        }
        return SongTile(tunes: sorted, index: index - 1);
      },
    );
  }
}
