import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/ui/album/album_view.dart';
import 'package:tunely/ui/common/album_art.dart';

class AlbumBox extends StatelessWidget {
  const AlbumBox({super.key, required this.album});
  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: REPLACE WITH ALBUMVIEW PUSH
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumView(albumId: album.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AlbumArt(
                id: album.id,
                size: const Size(double.infinity, double.infinity),
                type: .ALBUM,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.album,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${album.artist ?? 'Unknown Artist'} • ${album.numOfSongs} Songs",
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
