import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_song_page.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_songs_view.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';

class TopSongsSection extends StatefulWidget {
  const TopSongsSection({super.key});

  @override
  State<TopSongsSection> createState() => _TopSongsSectionState();
}

class _TopSongsSectionState extends State<TopSongsSection> {
  final PageController _topSongsController = PageController();
  int _currentTopSongPage = 0;

  @override
  void initState() {
    super.initState();
    _topSongsController.addListener(() {
      final page = _topSongsController.page?.round() ?? 0;
      if (page != _currentTopSongPage) {
        setState(() => _currentTopSongPage = page);
      }
    });
  }

  @override
  void dispose() {
    _topSongsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      buildWhen: (prev, curr) => curr is StatsLoaded,
      builder: (context, state) {
        if (state is! StatsLoaded || state.mostPlayed.isEmpty) {
          return const SizedBox.shrink();
        }

        final topSongs = state.mostPlayed.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Songs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    onPressed: () {
                      context.read<PlaybackBloc>().add(
                        PlayQueueEvent(state.mostPlayed, startIndex: 0),
                      );
                    },
                    label: Text('Play ${state.mostPlayed.length} songs'),
                    icon: const Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _topSongsController,
                itemCount: topSongs.length + 1,
                itemBuilder: (context, i) {
                  if (i == topSongs.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _allTopSongsCard(state.mostPlayed.length),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TopSongWidget(
                      tune: topSongs[i],
                      queue: topSongs,
                      index: i,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  topSongs.length + 1,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentTopSongPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentTopSongPage == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withAlpha(50),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _allTopSongsCard(int totalCount) {
    return Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'All $totalCount Top Songs',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TopSongsView()));
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('View All'),
            ),
          ],
        ),
      ),
    );
  }
}
