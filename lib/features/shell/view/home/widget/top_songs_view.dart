import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_carousel.dart';
import 'package:tunely/shared/widget/song_action_row.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';

class TopSongsView extends StatelessWidget {
  const TopSongsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        final tunes = state is StatsLoaded ? state.mostPlayed : <Tune>[];
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
                actions: [
                  if (tunes.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      tooltip: 'Clear all',
                      onPressed: () => _confirmClear(context),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: AlbumCarousel(tunes: tunes, title: 'Top Songs'),
                ),
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

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all play counts?'),
        content: const Text(
          'This will reset play counts for all songs. Top songs will be empty until you play more music.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StatsCubit>().clearAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
