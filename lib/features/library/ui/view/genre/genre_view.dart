import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/album_carousel.dart';
import 'package:tunely/shared/widget/song_action_row.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';

class GenreView extends StatelessWidget {
  const GenreView({super.key, required this.genre});
  final GenreModel genre;

  @override
  Widget build(BuildContext context) {
    final tunes = context.read<LibraryCubit>().getTunesByGenre(genre.genre);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: AlbumCarousel(tunes: tunes, title: genre.genre),
            ),
          ),
          SongActionRowSliver(tunes: tunes),
          TuneSliverList(tunes: tunes),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}
