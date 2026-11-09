import 'package:flutter/material.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/song_tile.dart';
import 'package:tunely/shared/model/tune.dart';

/// Draggable row in the "Selected Songs" list.
class SelectedSongTile extends StatelessWidget {
  const SelectedSongTile({
    super.key,
    required this.tune,
    required this.index,
    required this.onRemove,
  });

  final Tune tune;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: PlaylistSongTile(
        tune: tune,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                color: theme.colorScheme.error.withAlpha(180),
              ),
              onPressed: onRemove,
              tooltip: 'Remove from playlist',
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.drag_handle_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
