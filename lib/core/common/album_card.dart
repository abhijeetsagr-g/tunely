import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/ui/album/album_view.dart';

class AlbumCard extends StatelessWidget {
  final AlbumModel album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await context.read<QueryCubit>().getFilteredSongs(
          AudiosFromType.ALBUM_ID,
          album.id,
        );

        if (context.mounted) {
          final tunes = context
              .read<QueryCubit>()
              .state
              .filteredSongs
              .map((element) => Tune.fromSongModel(element))
              .toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlbumView(album: album, tunes: tunes),
            ),
          );
        }
      },
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArt(
              id: album.id,
              type: ArtworkType.ALBUM,
              size: Size(180, 180),
            ),
            const SizedBox(height: 6),
            Text(
              album.album.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              album.artist ?? "Unknown Artist",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
