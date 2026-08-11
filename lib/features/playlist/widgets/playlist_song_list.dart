import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class PlaylistSongList extends StatefulWidget {
  const PlaylistSongList({
    super.key,
    required this.tunes,
    this.initialSelected = const {},
    this.onSelectionChanged,
  });

  final List<Tune> tunes;
  final Set<int> initialSelected;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  State<PlaylistSongList> createState() => _PlaylistSongListState();
}

class _PlaylistSongListState extends State<PlaylistSongList> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<int> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlaylistSongList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.initialSelected, widget.initialSelected)) {
      _selected
        ..clear()
        ..addAll(widget.initialSelected);
    }
  }

  List<Tune> get _visibleTunes {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.tunes;
    return widget.tunes
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.artists.any((a) => a.toLowerCase().contains(q)),
        )
        .toList();
  }

  List<Tune> get _orderedTunes {
    final visible = _visibleTunes;
    return [
      ...visible.where((t) => _selected.contains(t.songId)),
      ...visible.where((t) => !_selected.contains(t.songId)),
    ];
  }

  void _toggle(Tune tune) {
    final id = tune.songId;
    if (id == null) return;
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
    widget.onSelectionChanged?.call(Set.from(_selected));
  }

  void _clearSelection() {
    if (_selected.isEmpty) return;
    setState(_selected.clear);
    widget.onSelectionChanged?.call({});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final visible = _orderedTunes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 10),
          child: Text(
            'Add Songs',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),

        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search songs',
            hintStyle: TextStyle(
              color: cs.onSurface.withAlpha(100),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: cs.onSurface.withAlpha(140),
              size: 20,
            ),
            suffixIcon: ListenableBuilder(
              listenable: _searchController,
              builder: (_, _) => _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: cs.onSurface.withAlpha(140),
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withAlpha(180),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),

        for (var index = 0; index < visible.length; index++)
          _buildTile(context, visible, index),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          child: Row(
            children: [
              Icon(Icons.music_note_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                '${_selected.length} songs selected',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _selected.isEmpty ? null : _clearSelection,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, List<Tune> tunes, int index) {
    final tune = tunes[index];
    final isSelected = _selected.contains(tune.songId);
    return SongTile(
      tunes: tunes,
      index: index,
      onTap: () => _toggle(tune),
      dontPlay: true,
      trailing: Icon(isSelected ? Icons.check_circle : Icons.add_circle),
    );
  }
}
