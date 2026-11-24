import 'package:flutter/material.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/song_tile.dart';
import 'package:tunely/shared/widget/staggered_reveal.dart';

class TuneSliverList extends StatelessWidget {
  const TuneSliverList({
    super.key,
    required this.tunes,
    this.onRemove,
    this.staggered = false,
  });

  final List<Tune> tunes;
  final void Function(int songId)? onRemove;

  /// Reveals rows one after another when the list is first built.
  final bool staggered;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: tunes.length,
      itemBuilder: (context, index) {
        final tune = tunes[index];
        final Widget tile;

        if (onRemove == null) {
          tile = SongTile(tunes: tunes, index: index);
        } else {
          tile = _TuneSliverItem(
            key: ValueKey(tune.songId ?? tune.path),
            tune: tune,
            onRemove: () {
              final id = tune.songId;
              if (id != null) onRemove?.call(id);
            },
          );
        }

        if (!staggered) return tile;

        return StaggeredReveal(
          key: ValueKey('reveal-${tune.path}'),
          index: index,
          child: tile,
        );
      },
    );
  }
}

class _TuneSliverItem extends StatelessWidget {
  const _TuneSliverItem({super.key, required this.tune, this.onRemove});

  final Tune tune;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: AlbumArt(artUri: tune.artUri, size: const Size(46, 46)),
      title: Text(
        tune.title.toTitleCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        tune.artists.join(" • "),
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
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
