import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        if (state is! StatsLoaded) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        final recent = state.mostPlayed;
        if (recent.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No recent songs")),
          );
        }

        return SliverList.builder(
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final tune = recent[index];
            return ListTile(
              title: Text(tune.title),
              subtitle: Text(tune.artist),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
