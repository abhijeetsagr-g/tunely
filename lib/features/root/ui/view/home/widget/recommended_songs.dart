import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/song_tile.dart';
import 'package:tunely/features/root/ui/view/home/widget/home_sections.dart';

class RecommendedSongs extends StatelessWidget {
  const RecommendedSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (prev, curr) => curr is LibraryLoaded,
      builder: (context, state) {
        if (state is! LibraryLoaded) return const SliverToBoxAdapter();
        final songs = [...state.tunes]..shuffle();
        final picked = songs.take(5).toList();

        if (picked.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Center(child: Text('No songs found')),
            ),
          );
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: HomeSections(
                headline: 'Recommended Songs',
                onTap: () {},
                child: const SizedBox.shrink(),
              ),
            ),
            SliverList.builder(
              itemCount: picked.length,
              itemBuilder: (context, i) => SongTile(tunes: picked, index: i),
            ),
          ],
        );
      },
    );
  }
}
