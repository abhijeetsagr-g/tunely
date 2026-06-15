import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

void showSongPickerSheet(
  BuildContext context, {
  required void Function(Tune tune) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SongPickerSheet(onSelected: onSelected),
  );
}

class SongPickerSheet extends StatefulWidget {
  final void Function(Tune tune) onSelected;

  const SongPickerSheet({super.key, required this.onSelected});

  @override
  State<SongPickerSheet> createState() => _SongPickerSheetState();
}

class _SongPickerSheetState extends State<SongPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Tune> _allTunes = [];
  List<Tune> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadTunes();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _loadTunes() {
    final library = context.read<LibraryCubit>().state;
    if (library is LibraryLoaded) {
      _allTunes = library.tunes;
      _filtered = _allTunes;
    }
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _allTunes;
      } else {
        _filtered = _allTunes
            .where(
              (t) =>
                  t.title.toLowerCase().contains(q) ||
                  t.artist.toLowerCase().contains(q) ||
                  t.album.toLowerCase().contains(q),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playback = context.watch<PlaybackBloc>().state;
    final currentPath = playback.currentItem?.path;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(20),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Pick a song',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No songs found',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final tune = _filtered[index];
                          final isCurrent = tune.path == currentPath;
                          return ListTile(
                            leading: AlbumArt(
                              id: tune.songId,
                              type: ArtworkType.AUDIO,
                              size: const Size(46, 46),
                            ),
                            title: Text(
                              tune.title.toTitleCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              tune.artists.join(' • '),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  150,
                                ),
                              ),
                            ),
                            trailing: isCurrent
                                ? Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(tune);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
