import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/utlis/sort.dart';
import 'package:tunely/features/library/ui/widget/sort_bar.dart';
import 'package:tunely/shared/widget/album_card.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({
    super.key,
    required this.albums,
    required this.durations,
    required this.sortType,
    required this.ascending,
    required this.onSortChanged,
    required this.onDirectionChanged,
    required this.hideSingles,
    required this.onHideSinglesChanged,
  });

  final List<AlbumModel> albums;
  final Map<int, Duration> durations;
  final AlbumSort sortType;
  final bool ascending;
  final ValueChanged<AlbumSort> onSortChanged;
  final ValueChanged<bool> onDirectionChanged;
  final bool hideSingles;
  final ValueChanged<bool> onHideSinglesChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = Sort.sortAlbums(
      albums,
      durations: durations,
      type: sortType,
      ascending: ascending,
    );
    final visible = hideSingles
        ? sorted.where((album) => album.numOfSongs > 1).toList()
        : sorted;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SortBar<AlbumSort>(
            options: const [
              SortOption(label: 'Name', value: AlbumSort.name),
              SortOption(label: 'Duration', value: AlbumSort.duration),
              SortOption(label: 'No. of Songs', value: AlbumSort.songCount),
            ],
            selected: sortType,
            onSelected: onSortChanged,
            ascending: ascending,
            onDirectionChanged: onDirectionChanged,
            trailing: IconButton(
              onPressed: () => onHideSinglesChanged(!hideSingles),
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
              ? const Center(child: Text('No albums found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      AlbumCard(width: 180, album: visible[index]),
                ),
        ),
      ],
    );
  }
}
