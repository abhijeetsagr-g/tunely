import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/widget/album_card.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({super.key, required this.albums});
  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: albums.length,
      itemBuilder: (context, index) =>
          AlbumCard(album: albums[index], width: 180),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78, // slightly taller than wide (art + title below)
      ),
    );
  }
}
