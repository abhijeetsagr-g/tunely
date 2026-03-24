import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/ui/common/album_box.dart';

class RecommendedAlbums extends StatelessWidget {
  const RecommendedAlbums({super.key});

  void play() {}

  @override
  Widget build(BuildContext context) {
    final all = context.read<LibraryCubit>().albums;
    final albums = (List.of(all)).take(5).toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 10, 0),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  "Albums",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                TextButton.icon(
                  onPressed: () {
                    // TODO: Open AlbumListView
                  },
                  icon: const Icon(Icons.keyboard_arrow_down),
                  label: const Text("Show All"),
                ),
              ],
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
              return AlbumBox(album: album);
            }, childCount: albums.length),
          ),
        ),
      ],
    );
  }
}
