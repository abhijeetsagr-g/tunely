import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';

class SongSortBar extends StatelessWidget {
  final SortType sortType;
  final SortOrder sortOrder;
  final ValueChanged<SortType> onSortTypeChanged;
  final VoidCallback onSortOrderToggled;

  const SongSortBar({
    super.key,
    required this.sortType,
    required this.sortOrder,
    required this.onSortTypeChanged,
    required this.onSortOrderToggled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: SortType.values.map((type) {
                  final selected = type == sortType;
                  return ChoiceChip(
                    label: Text(_sortTypeLabel(type)),
                    selected: selected,
                    onSelected: (_) => onSortTypeChanged(type),
                    selectedColor: colorScheme.primaryColor,
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            tooltip: sortOrder == SortOrder.ascending
                ? 'Ascending'
                : 'Descending',
            onPressed: onSortOrderToggled,
            icon: Icon(
              sortOrder == SortOrder.ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: colorScheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _sortTypeLabel(SortType type) => switch (type) {
    SortType.name => 'Name',
    SortType.duration => 'Duration',
    SortType.album => 'Album',
    SortType.artist => 'Artist',
    SortType.dateAdded => 'Date Added',
  };
}
