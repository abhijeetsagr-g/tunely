import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';

class AlbumList extends StatelessWidget {
  const AlbumList({super.key, required this.albums});
  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const Center(child: Text("No albums found"));
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AlbumArt(
              id: album.id,
              size: const Size(48, 48),
              type: ArtworkType.ALBUM,
            ),
          ),
          title: Text(
            album.album.toTitleCase(),
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${album.artist?.toTitleCase() ?? 'Unknown'} · ${album.numOfSongs} tracks",
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            final tunes = context.read<QueryCubit>().tunesByAlbum(album.id);
            Navigator.pushNamed(
              context,
              AppRoutes.album,
              arguments: AlbumViewArgs(album: album, tunes: tunes),
            );
          },
        );
      },
    );
  }
}
