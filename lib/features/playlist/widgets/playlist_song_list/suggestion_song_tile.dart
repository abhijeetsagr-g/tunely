import 'package:flutter/material.dart';
import 'package:tunely/features/playlist/widgets/playlist_song_list/song_tile.dart';
import 'package:tunely/shared/model/tune.dart';

/// Row shown in the "Add Songs" suggestions list.
class SuggestionSongTile extends StatelessWidget {
  const SuggestionSongTile({
    super.key,
    required this.tune,
    required this.onAdd,
  });

  final Tune tune;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return PlaylistSongTile(
      tune: tune,
      onTap: onAdd,
      trailing: const Icon(Icons.add_circle),
    );
  }
}
