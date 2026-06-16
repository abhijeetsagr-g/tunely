import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/features/library/ui/view/songs/song_sort_bar.dart';
import 'package:tunely/features/playlist/view/widget/playlist_actions.dart';
import 'package:tunely/features/playlist/view/widget/playlist_hero.dart';
import 'package:tunely/features/playlist/view/widget/playlist_song_list.dart';
import 'package:tunely/shared/model/tune.dart';

class PlaylistLoadedView extends StatefulWidget {
  const PlaylistLoadedView({
    super.key,
    required this.playlist,
    required this.tunes,
    required this.sortType,
    required this.sortOrder,
    required this.onSortTypeChanged,
    required this.onSortOrderToggled,
    required this.onRemove,
  });

  final PlaylistModel playlist;
  final List<Tune> tunes;
  final SortType sortType;
  final SortOrder sortOrder;
  final void Function(SortType type) onSortTypeChanged;
  final VoidCallback onSortOrderToggled;
  final void Function(int songId) onRemove;

  @override
  State<PlaylistLoadedView> createState() => _PlaylistLoadedViewState();
}

class _PlaylistLoadedViewState extends State<PlaylistLoadedView> {
  bool _isEditing = false;

  void _toggleEditing() => setState(() => _isEditing = !_isEditing);

  @override
  Widget build(BuildContext context) {
    final sorted = sortTunes(widget.tunes, widget.sortType, widget.sortOrder);

    return CustomScrollView(
      slivers: [
        PlaylistHeroSliver(
          playlist: widget.playlist,
          tunes: widget.tunes,
          onEditToggle: _toggleEditing,
        ),
        PlaylistActionRowSliver(
          tunes: widget.tunes,
          playlist: widget.playlist,
          isEditing: _isEditing,
        ),
        if (_isEditing && widget.tunes.isNotEmpty)
          SliverToBoxAdapter(
            child: SongSortBar(
              sortType: widget.sortType,
              sortOrder: widget.sortOrder,
              onSortTypeChanged: widget.onSortTypeChanged,
              onSortOrderToggled: widget.onSortOrderToggled,
              types: [
                SortType.name,
                SortType.duration,
                SortType.album,
                SortType.artist,
                SortType.dateAdded,
              ],
            ),
          ),
        if (widget.tunes.isNotEmpty)
          PlaylistSongListSliver(
            tunes: _isEditing ? sorted : widget.tunes,
            onRemove: _isEditing ? widget.onRemove : null,
          )
        else
          _EmptySliver(playlist: widget.playlist),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _EmptySliver extends StatelessWidget {
  const _EmptySliver({required this.playlist});
  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off_rounded, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No songs yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Add songs to this playlist\nfrom your library.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistErrorView extends StatelessWidget {
  const PlaylistErrorView({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
