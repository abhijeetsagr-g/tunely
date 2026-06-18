import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/total_song_dur.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';
import 'package:tunely/shared/widget/song_action_row.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.album});
  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    final tunes = context.read<LibraryCubit>().getTunesByAlbum(album.id);
    final totalDuration = tunes.fold<double>(
      0,
      (sum, tune) => sum + tune.duration.inMilliseconds,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlbumArt(
                    size: Size(150, 150),
                    id: album.id,
                    type: ArtworkType.ALBUM,
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          album.album.toTitleCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                fontSize: 20,
                              ),
                        ),
                        Text(
                          album.artist?.toTitleCase() ?? "Unknown Artist",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          "${totalTunesDurations(totalDuration)} | ${album.numOfSongs} Tunes",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SongActionRowSliver(tunes: tunes),
          TuneSliverList(tunes: tunes),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}
