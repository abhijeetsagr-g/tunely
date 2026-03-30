import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/shared/widgets/song_tile.dart';
import 'package:tunely/features/history/history_cubit.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    final recent = context.select<HistoryCubit, List>(
      (c) => c.state.recentTunes,
    );
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Recently Played",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...recent.map(
          (tune) => SongTile(
            tune: tune,
            index: recent.indexOf(tune),
            tunes: recent as List<Tune>,
          ),
        ),
      ],
    );
  }
}
