import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.id,
    required this.size,
    required this.type,
  });
  final int id;
  final Size size;
  final ArtworkType type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: QueryArtworkWidget(
        id: id,
        type: type,
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        artworkBorder: BorderRadius.circular(4),
        nullArtworkWidget: Container(
          color: Colors.grey.shade900,
          child: const Icon(Icons.music_note, color: Colors.white54),
        ),
      ),
    );
  }
}
