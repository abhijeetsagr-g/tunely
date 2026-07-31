import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key, required this.playlists});

  final List<PlaylistModel> playlists;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('${playlists.length} playlists'));
  }
}
