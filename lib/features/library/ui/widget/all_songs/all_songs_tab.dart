import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort.dart';
import 'package:tunely/features/library/ui/widget/sort_bar.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class AllSongsTab extends StatelessWidget {
  const AllSongsTab({
    super.key,
    required this.tunes,
    required this.sortType,
    required this.ascending,
    required this.onSortChanged,
    required this.onDirectionChanged,
  });

  final List<Tune> tunes;
  final TuneSortType sortType;
  final bool ascending;
  final ValueChanged<TuneSortType> onSortChanged;
  final ValueChanged<bool> onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    final sorted = Sort.sortTunes(tunes, type: sortType, ascending: ascending);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SortBar<TuneSortType>(
            options: const [
              SortOption(label: 'Name', value: TuneSortType.name),
              SortOption(label: 'Date Added', value: TuneSortType.dateAdded),
              SortOption(label: 'Duration', value: TuneSortType.duration),
            ],
            selected: sortType,
            onSelected: onSortChanged,
            ascending: ascending,
            onDirectionChanged: onDirectionChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) =>
                SongTile(tunes: sorted, index: index),
          ),
        ),
      ],
    );
  }
}
