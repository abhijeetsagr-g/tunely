// _playlist_tile.dart (private widget, can live in same file)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/view/playlist_detailed_view.dart';
import 'package:tunely/features/playlist/view/widget/add_songs_sheet.dart';

enum _PlaylistAction { rename, addSongs, delete }

class PlaylistTile extends StatelessWidget {
  final PlaylistModel playlist;
  const PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.queue_music)),
      title: Text(
        playlist.playlist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text("${playlist.numOfSongs} songs"),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: PlaylistDetailView(playlist: playlist),
            ),
          ),
        );
      },
      trailing: PopupMenuButton<_PlaylistAction>(
        onSelected: (action) => _handleAction(context, action, playlist, cubit),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _PlaylistAction.rename,
            child: ListTile(
              leading: Icon(Icons.drive_file_rename_outline),
              title: Text("Rename"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _PlaylistAction.addSongs,
            child: ListTile(
              leading: Icon(Icons.library_add_outlined),
              title: Text("Add songs"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _PlaylistAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text("Delete"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    _PlaylistAction action,
    PlaylistModel playlist,
    PlaylistCubit cubit,
  ) {
    switch (action) {
      case _PlaylistAction.rename:
        _showRenameDialog(context, playlist, cubit);
      case _PlaylistAction.addSongs:
        _showAddSongsSheet(context, playlist, cubit);
      case _PlaylistAction.delete:
        _showDeleteConfirm(context, playlist, cubit);
    }
  }

  void _showRenameDialog(
    BuildContext context,
    PlaylistModel playlist,
    PlaylistCubit cubit,
  ) {
    final controller = TextEditingController(text: playlist.playlist);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename playlist"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Playlist name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) cubit.renamePlaylist(playlist.id, name);
              Navigator.pop(context);
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    PlaylistModel playlist,
    PlaylistCubit cubit,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete playlist?"),
        content: Text("\"${playlist.playlist}\" will be permanently deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              cubit.removePlaylist(playlist.id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddSongsSheet(
    BuildContext context,
    PlaylistModel playlist,
    PlaylistCubit cubit,
  ) {
    // Pulls tunes from LibraryCubit — adjust if you source them differently
    final allTunes = context.read<LibraryCubit>().state;
    if (allTunes is! LibraryLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddSongsSheet(
        playlist: playlist,
        tunes: allTunes.tunes,
        cubit: cubit,
      ),
    );
  }
}
