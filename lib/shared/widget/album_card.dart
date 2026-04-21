import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, this.width = 120});
  final AlbumModel album;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoute.album,
        arguments: AlbumSettingsArguments(album),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlbumArt(
            size: Size(width, width),
            artUri: Uri.parse(
              'content://media/external/audio/albumart/${album.id}',
            ),
          ),
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
      ),
    );
  }
}
