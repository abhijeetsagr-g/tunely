import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/cubit/library_state.dart';

import 'package:tunely/shared/widgets/artist_chip.dart';

class ArtistWrap extends StatelessWidget {
  const ArtistWrap({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      buildWhen: (previous, current) =>
          previous.sortedTunes != current.sortedTunes,
      builder: (context, state) {
        final artists = context.read<LibraryCubit>().artists;

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: artists.map((artist) {
                    return ArtistChip(id: artist.id, artistName: artist.artist);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
