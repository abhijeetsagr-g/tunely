import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoaded) {
          final tunes = state.tunes;
          return ListView.builder(
            itemCount: tunes.length,
            itemBuilder: (context, index) {
              return SongTile(tunes: tunes, index: index);
            },
          );
        }
        return Center(child: Text("No Songs Available"));
      },
    );
  }
}
