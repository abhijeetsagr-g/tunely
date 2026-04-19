import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';
import 'package:tunely/features/root/ui/view/home/widget/home_sections.dart';

class RecommendedSongs extends StatefulWidget {
  const RecommendedSongs({super.key});

  @override
  State<RecommendedSongs> createState() => _RecommendedSongsState();
}

class _RecommendedSongsState extends State<RecommendedSongs> {
  List<Tune> _picked = [];

  void _reshuffle(List<Tune> tunes) {
    setState(() {
      _picked = ([...tunes]..shuffle()).take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (prev, curr) => curr is LibraryLoaded,
      builder: (context, state) {
        if (state is! LibraryLoaded) return const SliverToBoxAdapter();

        if (_picked.isEmpty) {
          _picked = ([...state.tunes]..shuffle()).take(5).toList();
        }

        if (_picked.isEmpty) {
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
                onTap: () => _reshuffle(state.tunes),
                child: const SizedBox.shrink(),
              ),
            ),
            SliverList.builder(
              itemCount: _picked.length,
              itemBuilder: (context, i) => SongTile(tunes: _picked, index: i),
            ),
          ],
        );
      },
    );
  }
}
