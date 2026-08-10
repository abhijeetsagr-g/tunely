import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        if (state is StatsLoaded) {
          final recent = state.recent;

          return SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Text(
                    "Recently Played",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (recent.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: Center(child: Text('No songs available')),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: (recent.length < 5 ? recent.length : 5) + 1,
                  itemBuilder: (context, i) {
                    final lastIndex = recent.length < 5 ? recent.length : 5;
                    if (i == lastIndex) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text("See all recently played"),
                          trailing: const Icon(
                            Icons.arrow_circle_right_outlined,
                          ),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoute.recent),
                        ),
                      );
                    }
                    return SongTile(tunes: recent, index: i);
                  },
                ),
            ],
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
