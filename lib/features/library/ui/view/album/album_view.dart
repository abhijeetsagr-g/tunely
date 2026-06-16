import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/widget/album_art.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.album});
  final AlbumModel album;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            stretch: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: AlbumArt(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    size: size,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
