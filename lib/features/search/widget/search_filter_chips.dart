import 'package:flutter/material.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';

class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({
    super.key,
    required this.active,
    required this.onSelect,
  });

  final FilterMode active;
  final ValueChanged<FilterMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final mode in FilterMode.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Chip(active: active, mode: mode, onSelect: onSelect),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.active,
    required this.mode,
    required this.onSelect,
  });

  final FilterMode active;
  final FilterMode mode;
  final ValueChanged<FilterMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = active == mode;
    final label = switch (mode) {
      FilterMode.all => 'All',
      FilterMode.songs => 'Songs',
      FilterMode.artists => 'Artists',
      FilterMode.albums => 'Albums',
    };

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelect(selected ? FilterMode.all : mode),
      selectedColor: cs.primaryContainer,
      checkmarkColor: cs.onPrimaryContainer,
      labelStyle: TextStyle(
        color: selected ? cs.onPrimaryContainer : cs.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
