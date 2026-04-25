import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/playlist/view/widget/playlist_card.dart';

class PlaylistList extends StatelessWidget {
  const PlaylistList({super.key, required this.playlists});

  final List<PlaylistModel> playlists;

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(
              'No playlists yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        return PlaylistCard(playlist: playlists[index]);
      },
    );
  }
}
