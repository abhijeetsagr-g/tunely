import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/shared/widget/album_art.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({super.key, required this.album, this.onTap});
  final AlbumModel album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
        Navigator.pushNamed(
          context,
          AppRoute.album,
          arguments: AlbumSettingsArguments(album),
        );
      },
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: AlbumArt(
          id: album.id,
          type: ArtworkType.ALBUM,
          size: const Size(46, 46),
        ),
        title: Text(
          album.album,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          album.artist ?? "Unknown Artist",
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
