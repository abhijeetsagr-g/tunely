import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/widget/album_card.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key, required this.albums});

  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const Center(child: Text('No albums found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) =>
          AlbumCard(width: 180, album: albums[index]),
    );
  }
}
