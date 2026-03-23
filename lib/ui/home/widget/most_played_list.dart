import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/ui/common/song_tile.dart';
import 'package:tunely/logic/provider/history/history_cubit.dart';

class MostPlayedList extends StatelessWidget {
  const MostPlayedList({super.key});

  @override
  Widget build(BuildContext context) {
    final top = context.select<HistoryCubit, List>((c) => c.state.topTunes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Most Played",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...top.map(
          (tune) => SongTile(
            tune: tune,
            index: top.indexOf(tune),
            tunes: top as List<Tune>,
          ),
        ),
      ],
    );
  }
}
