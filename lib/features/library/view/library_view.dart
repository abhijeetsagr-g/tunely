import 'package:flutter/material.dart';
import 'package:tunely/shared/widgets/segmented_control.dart';
import 'package:tunely/features/library/view/widget/library_album_list.dart';
import 'package:tunely/features/library/view/widget/library_song_list.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  LibraryFilter current = LibraryFilter.songs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedControl(
                current: current,
                onChanged: (val) => setState(() => current = val),
              ),
            ),
          ),

          ..._buildSlivers(),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers() {
    switch (current) {
      case LibraryFilter.songs:
        return const [LibrarySongList()];

      case LibraryFilter.albums:
        return const [LibraryAlbumList()];

      case LibraryFilter.artists:
        return const [
          SliverFillRemaining(child: Center(child: Text("Artists"))),
        ];
    }
  }
}
