import 'package:flutter/material.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

/// Shared base row for playlist picker tiles.
class PlaylistSongTile extends StatelessWidget {
  const PlaylistSongTile({
    super.key,
    required this.tune,
    this.onTap,
    this.trailing,
  });

  final Tune tune;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: AlbumArt(artUri: tune.artUri, size: const Size(46, 46)),
      title: Text(
        tune.title.toTitleCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        tune.artists.join(" • "),
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
      ),
      trailing: trailing,
    );
  }
}
