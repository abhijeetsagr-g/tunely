import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';

class StatsTestView extends StatelessWidget {
  const StatsTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats Test')),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsInitial) {
            return const Center(child: Text('Not loaded yet'));
          }

          if (state is StatsLoaded) {
            return ListView(
              children: [
                _Section(
                  title: '🔥 Most Played',
                  tunes: state.mostPlayed,
                  subtitle: (t) =>
                      '${context.read<StatsCubit>().repo.get(t.path).playCount} plays',
                ),
                _Section(
                  title: '🕐 Recently Played',
                  tunes: state.recent,
                  subtitle: (t) {
                    final last = context
                        .read<StatsCubit>()
                        .repo
                        .get(t.path)
                        .lastPlayed;
                    return last != null ? last.toString() : 'Never';
                  },
                ),
                _Section(
                  title: '❤️ Liked',
                  tunes: state.liked,
                  subtitle: (_) => 'Liked',
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List tunes;
  final String Function(dynamic) subtitle;

  const _Section({
    required this.title,
    required this.tunes,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (tunes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Empty', style: TextStyle(color: Colors.grey)),
          )
        else
          ...tunes.map(
            (t) => ListTile(
              title: Text(
                t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(subtitle(t)),
              leading: const Icon(Icons.music_note),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
