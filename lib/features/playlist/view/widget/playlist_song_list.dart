import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class PlaylistSongListSliver extends StatelessWidget {
  const PlaylistSongListSliver({
    super.key,
    required this.tunes,
    this.onRemove,
  });

  final List<Tune> tunes;
  final void Function(int songId)? onRemove;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: tunes.length,
      itemBuilder: (context, index) {
        if (onRemove == null) {
          return SongTile(tunes: tunes, index: index);
        }
        final tune = tunes[index];
        return _PlaylistSongItem(
          key: ValueKey(tune.songId ?? tune.path),
          tune: tune,
          onRemove: () {
            final id = tune.songId;
            if (id != null) onRemove?.call(id);
          },
        );
      },
    );
  }
}

class _PlaylistSongItem extends StatelessWidget {
  const _PlaylistSongItem({
    super.key,
    required this.tune,
    this.onRemove,
  });

  final Tune tune;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      leading: AlbumArt(
        id: tune.songId,
        type: ArtworkType.AUDIO,
        size: const Size(46, 46),
      ),
      title: Text(
        tune.title.toTitleCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        tune.artists.join(" • "),
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
      ),
      trailing: onRemove != null
          ? IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                color: theme.colorScheme.error.withAlpha(180),
              ),
              onPressed: onRemove,
              tooltip: 'Remove from playlist',
            )
          : null,
    );
  }
}
