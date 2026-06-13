import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/mini_song_tile.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Tune> recent = context.select<StatsCubit, List<Tune>>((cubit) {
      final state = cubit.state;
      if (state is StatsLoaded) return state.recent;
      return [];
    });

    if (recent.isEmpty) return const SizedBox.shrink();

    final items = recent.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.2,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => MiniSongTile(tunes: items, index: i),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
