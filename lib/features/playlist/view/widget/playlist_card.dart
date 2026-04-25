import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist});

  final PlaylistModel playlist;

  void _showRenameDialog(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();
    final controller = TextEditingController(text: playlist.playlist);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              cubit.renamePlaylist(playlist.id, name);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete playlist'),
        content: Text('Delete "${playlist.playlist}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.deletePlaylist(playlist.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songCount = playlist.numOfSongs;

    return Dismissible(
      key: ValueKey(playlist.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showDeleteDialog(context);
        } else {
          _showRenameDialog(context);
        }
        return false; // always false — dialogs handle the action
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.drive_file_rename_outline, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: AlbumArt(artUri: null, size: const Size(52, 52)),
        title: Text(
          playlist.playlist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          '$songCount ${songCount == 1 ? 'song' : 'songs'}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoute.playlist,
          arguments: PlaylistSettingsArguments(playlist: playlist),
        ),
      ),
    );
  }
}
