import 'package:flutter/material.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_card.dart';

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key, required this.artists});

  final List<Artist> artists;

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) {
      return const Center(child: Text('No artists found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: artists.length,
      itemBuilder: (context, index) => ArtistCard(artist: artists[index]),
    );
  }
}
