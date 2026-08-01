import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/sort.dart';
import 'package:tunely/features/library/ui/widget/sort_bar.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_card.dart';

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({
    super.key,
    required this.artists,
    required this.sortType,
    required this.ascending,
    required this.onSortChanged,
    required this.onDirectionChanged,
    required this.hideSingles,
    required this.onHideSinglesChanged,
  });

  final List<Artist> artists;
  final ArtistSort sortType;
  final bool ascending;
  final ValueChanged<ArtistSort> onSortChanged;
  final ValueChanged<bool> onDirectionChanged;
  final bool hideSingles;
  final ValueChanged<bool> onHideSinglesChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = Sort.sortArtists(
      artists,
      type: sortType,
      ascending: ascending,
    );
    final visible = hideSingles
        ? sorted.where((artist) => artist.tunes.length > 1).toList()
        : sorted;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SortBar<ArtistSort>(
            options: const [
              SortOption(label: 'Name', value: ArtistSort.name),
              SortOption(label: 'No. of Songs', value: ArtistSort.songCount),
            ],
            selected: sortType,
            onSelected: onSortChanged,
            ascending: ascending,
            onDirectionChanged: onDirectionChanged,
            trailing: IconButton(
              onPressed: () => onHideSinglesChanged(!hideSingles),
              tooltip: 'Hide single-song artists',
              style: IconButton.styleFrom(
                backgroundColor: hideSingles
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
              ),
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.filter_alt_rounded,
                size: 20,
                color: hideSingles
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No artists found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      ArtistCard(artist: visible[index]),
                ),
        ),
      ],
    );
  }
}
