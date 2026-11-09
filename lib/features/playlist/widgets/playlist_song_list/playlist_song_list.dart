import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/playlist_selection_controller.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/section_header.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/selected_song_tile.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/song_search_field.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/suggestion_song_tile.dart';
import 'package:tunely/shared/model/tune.dart';

/// Two-section song picker: a short list of addable suggestions and a
/// reorderable list of selected songs.
class PlaylistSongList extends StatefulWidget {
  const PlaylistSongList({
    super.key,
    required this.tunes,
    this.initialSelected = const [],
    this.onSelectionChanged,
  });

  final List<Tune> tunes;

  /// Selected song paths, in playlist order.
  final List<String> initialSelected;
  final ValueChanged<List<String>>? onSelectionChanged;

  @override
  State<PlaylistSongList> createState() => _PlaylistSongListState();
}

class _PlaylistSongListState extends State<PlaylistSongList> {
  late final PlaylistSelectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlaylistSelectionController(
      tunes: widget.tunes,
      initialSelected: widget.initialSelected,
      onSelectionChanged: (paths) => widget.onSelectionChanged?.call(paths),
    );
  }

  @override
  void didUpdateWidget(PlaylistSongList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.tunes, widget.tunes)) {
      _controller.setTunes(widget.tunes, notify: false);
    }
    if (!listEquals(oldWidget.initialSelected, widget.initialSelected)) {
      _controller.setSelection(widget.initialSelected, notify: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final suggestions = _controller.suggestions;
        final selected = _controller.selectedTunes;

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Add Songs',
                      padding: const EdgeInsets.only(top: 24, bottom: 10),
                      trailing: Text(
                        'Up to ${_controller.maxSuggestions}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SongSearchField(onChanged: _controller.search),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: suggestions.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyMessage(
                        _controller.query.isEmpty
                            ? 'All songs are already in this playlist.'
                            : 'No matching songs to add.',
                      ),
                    )
                  : SliverList.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final tune = suggestions[index];
                        return SuggestionSongTile(
                          key: ValueKey(tune.path),
                          tune: tune,
                          onAdd: () => _controller.add(tune),
                        );
                      },
                    ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Selected Songs',
                  subtitle: '${selected.length}',
                  trailing: TextButton(
                    onPressed: selected.isEmpty
                        ? null
                        : _controller.clearSelection,
                    child: const Text('Clear'),
                  ),
                ),
              ),
            ),
            if (selected.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _EmptyMessage(
                    'Add songs above to build your playlist.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverReorderableList(
                  itemCount: selected.length,
                  onReorderItem: _controller.reorder,
                  itemBuilder: (context, index) {
                    final tune = selected[index];
                    return SelectedSongTile(
                      key: ValueKey(tune.path),
                      tune: tune,
                      index: index,
                      onRemove: () => _controller.remove(tune.path),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
