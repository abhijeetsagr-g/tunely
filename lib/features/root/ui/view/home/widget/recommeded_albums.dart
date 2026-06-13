import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/widget/album_card.dart';

class RecommendedAlbums extends StatelessWidget {
  const RecommendedAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<StatsCubit, StatsState>(
        buildWhen: (prev, curr) => curr is StatsLoaded,
        builder: (context, statsState) {
          if (statsState is! StatsLoaded || statsState.mostPlayed.isEmpty) {
            return const SizedBox();
          }

          final libraryState = context.watch<LibraryCubit>().state;
          if (libraryState is! LibraryLoaded) return const SizedBox();

          final topAlbumIds = statsState.mostPlayed
              .map((t) => t.albumId)
              .whereType<int>()
              .toSet();

          final topAlbums = libraryState.albums
              .where((a) => topAlbumIds.contains(a.id))
              .take(5)
              .toList();

          if (topAlbums.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your Albums',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: topAlbums.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (context, i) => AlbumCard(album: topAlbums[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
