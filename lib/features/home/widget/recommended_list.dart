import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/shared/widgets/song_tile.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/cubit/library_state.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';
import 'package:tunely/features/home/widget/section_header.dart';

class RecommendedList extends StatefulWidget {
  const RecommendedList({super.key});

  @override
  State<RecommendedList> createState() => _RecommendedListState();
}

class _RecommendedListState extends State<RecommendedList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (previous, current) =>
          previous.recommendedTunes != current.recommendedTunes,
      builder: (BuildContext context, LibraryState state) {
        final recommended = state.recommendedTunes;

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recommended Songs',
                buttonLabel: 'Play Everything you got',
                onButtonPressed: () => context.read<PlaybackBloc>().add(
                  ShuffleAll(tunes: state.sortedTunes),
                ),
                onRefresh: () =>
                    context.read<LibraryCubit>().refreshRecommended(),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SongTile(
                  tune: recommended[index],
                  index: index,
                  tunes: recommended,
                ),
                childCount: recommended.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
