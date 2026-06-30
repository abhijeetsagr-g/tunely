import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_carousel.dart';
import 'package:tunely/shared/widget/song_action_row.dart';

class DailyMixView extends StatelessWidget {
  const DailyMixView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final tunes = state is LibraryLoaded ? state.dailyMix : <Tune>[];
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
                  background: AlbumCarousel(tunes: tunes, title: 'Daily Mix'),
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        context.read<LibraryCubit>().reloadDailyMix(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              SongActionRowSliver(tunes: tunes),
              TuneSliverList(tunes: tunes),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        );
      },
    );
  }
}
