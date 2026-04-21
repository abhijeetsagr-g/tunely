import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/view/widget/playlist_tile.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        return switch (state) {
          PlaylistLoading() => const Center(child: CircularProgressIndicator()),
          PlaylistError(:final message) => Center(child: Text(message)),
          PlaylistLoaded(:final playlists) =>
            playlists.isEmpty
                ? const Center(child: Text("No playlists yet."))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return PlaylistTile(playlist: playlists[index]);
                    },
                  ),
          _ => const Center(child: Text("No Playlist Found")),
        };
      },
    );
  }
}
