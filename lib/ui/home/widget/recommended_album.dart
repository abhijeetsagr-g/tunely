import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/ui/common/album_box.dart';

class RecommendedAlbums extends StatelessWidget {
  const RecommendedAlbums({super.key});

  void play() {}

  @override
  Widget build(BuildContext context) {
    final albums = context.read<LibraryCubit>().albums;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 10, 0),
            child: Text(
              "Albums",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 5,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final album = albums[index];
              return AlbumBox(
                album: album,
                onTap: () {
                  //TODO: OPEN ALBUM VIEW
                },
              );
            }, childCount: albums.length),
          ),
        ),
      ],
    );
  }
}
