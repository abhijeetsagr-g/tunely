import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/shell/widget/show_all.dart';
import 'package:tunely/shared/widget/song_tile.dart';
import 'package:tunely/shared/widget/staggered_reveal.dart';

class DailyMixWidget extends StatefulWidget {
  const DailyMixWidget({super.key});

  @override
  State<DailyMixWidget> createState() => _DailyMixWidgetState();
}

class _DailyMixWidgetState extends State<DailyMixWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (prev, curr) => curr is LibraryLoaded,
      builder: (context, state) {
        if (state is! LibraryLoaded) return const SliverToBoxAdapter();

        final dailyMix = state.dailyMix;

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  "Daily Mix",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (dailyMix.isEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: Center(child: Text('No songs available')),
                ),
              )
            else
              SliverList.builder(
                itemCount: (dailyMix.length < 5 ? dailyMix.length : 5) + 1,
                itemBuilder: (context, i) {
                  final lastIndex = dailyMix.length < 5 ? dailyMix.length : 5;
                  if (i == lastIndex) {
                    return ShowAllToPage(
                      appRoute: AppRoute.dailyMix,
                      description: 'See what you have today!',
                    );
                  }
                  return StaggeredReveal(
                    key: ValueKey(dailyMix[i].path),
                    index: i,
                    child: SongTile(tunes: dailyMix, index: i),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
