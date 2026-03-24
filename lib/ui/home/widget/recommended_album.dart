import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/library/library_cubit.dart';
import 'package:tunely/ui/common/album_box.dart';

class RecommendedAlbums extends StatefulWidget {
  const RecommendedAlbums({super.key});

  @override
  State<RecommendedAlbums> createState() => _RecommendedAlbumsState();
}

class _RecommendedAlbumsState extends State<RecommendedAlbums> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final all = context.read<LibraryCubit>().albums;
    final albums = _expanded ? all : all.take(3).toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Albums",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  label: Text(_expanded ? "Show Less" : "Show All"),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 5,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => AlbumBox(album: albums[index]),
              childCount: albums.length,
            ),
          ),
        ),
      ],
    );
  }
}
