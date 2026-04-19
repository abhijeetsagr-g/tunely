import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_song_page.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';

class TopSongsCard extends StatefulWidget {
  const TopSongsCard({super.key});

  @override
  State<TopSongsCard> createState() => _TopSongsCardState();
}

class _TopSongsCardState extends State<TopSongsCard> {
  final _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  void _startTimer(int count) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % count;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        if (state is! StatsLoaded || state.mostPlayed.isEmpty) {
          return const SizedBox.shrink();
        }

        final songs = state.mostPlayed.take(5).toList();

        // Start timer once
        if (_timer == null) _startTimer(songs.length);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: songs.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) =>
                      TopSongPage(tune: songs[i], queue: songs, index: i),
                ),
              ),
              const SizedBox(height: 10),
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(songs.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(50),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
