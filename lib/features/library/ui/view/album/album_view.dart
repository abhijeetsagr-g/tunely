import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/total_song_dur.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/ui/view/album/widgets/artist_album_list.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';
import 'package:tunely/shared/widget/song_action_row.dart';

class AlbumView extends StatefulWidget {
  const AlbumView({super.key, required this.album});
  final AlbumModel album;

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  bool _artistsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    final tunes = cubit.getTunesByAlbum(widget.album.id);
    final totalDuration = tunes.fold<double>(
      0,
      (sum, tune) => sum + tune.duration.inMilliseconds,
    );
    final albumArtists = cubit.getArtistsFromTunes(tunes);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                    id: widget.album.id,
                    type: ArtworkType.ALBUM,
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          widget.album.album.toTitleCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                fontSize: 20,
                              ),
                        ),
                        Text(
                          widget.album.artist?.toTitleCase() ??
                              "Unknown Artist",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          "${totalTunesDurations(totalDuration)} | ${widget.album.numOfSongs} Tunes",
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
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: InkWell(
                onTap: () =>
                    setState(() => _artistsExpanded = !_artistsExpanded),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Artists in this Album",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      _artistsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_artistsExpanded) ArtistAlbumListSliver(artists: albumArtists),

          SliverToBoxAdapter(
            child: SizedBox(height: _artistsExpanded ? 16 : 96),
          ),
        ],
      ),
    );
  }
}
