import 'package:flutter/material.dart';
import 'package:tunely/features/root/ui/view/home/widget/playlist_section.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommeded_albums.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommended_songs.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: PlaylistSection(onTap: () {})),
        SliverToBoxAdapter(child: RecommendedAlbums()),
        RecommendedSongs(),
      ],
    );
  }
}
