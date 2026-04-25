import 'package:flutter/material.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/widget/artist_avater.dart';
import 'package:tunely/shared/widget/content_view.dart';

class ArtistView extends StatelessWidget {
  const ArtistView({super.key, required this.artist});
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContentView(
        title: artist.artist,
        tunes: artist.tunes,
        artWidget: ArtistAvatar(artist: artist, size: const Size(300, 300)),
      ),
    );
  }
}
