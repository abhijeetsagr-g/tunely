import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/cubit/library_state.dart';
import 'package:tunely/shared/widgets/song_tile.dart';

class LibrarySongList extends StatelessWidget {
  const LibrarySongList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (BuildContext context, LibraryState state) {
        return SliverList.builder(
          itemCount: state.sortedTunes.length,
          itemBuilder: (context, index) {
            return SongTile(
              tune: state.sortedTunes[index],
              index: index,
              tunes: state.sortedTunes,
            );
          },
        );
      },
    );
  }
}
