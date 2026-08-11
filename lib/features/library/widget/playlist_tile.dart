import 'package:flutter/material.dart';
import 'package:tunely/features/playlist/model/playlist.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onLongPress,
    this.onMenuPressed,
  });

  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songCount = playlist.songPaths.length;

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music_rounded,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        playlist.description?.isNotEmpty == true
            ? playlist.description!
            : '$songCount ${songCount == 1 ? 'song' : 'songs'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: onMenuPressed != null
          ? IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMenuPressed,
            )
          : null,
    );
  }
}
