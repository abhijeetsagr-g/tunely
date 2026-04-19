import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album});
  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlbumArt(id: album.id, size: Size(120, 120), type: ArtworkType.ALBUM),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            album.album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            formatArtistName(
              context.read<ManagementCubit>().state.artistDelimiters,
              album.artist ?? "Unknown Artist",
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
