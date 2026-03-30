import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/widgets/album_art.dart';

class ArtistImage extends StatelessWidget {
  const ArtistImage({
    super.key,
    required this.artistId,
    required this.size,
    required this.borderRadius,
  });
  final int artistId;
  final Size size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AlbumArt(id: artistId, size: size, type: ArtworkType.ARTIST),
    );
  }
}
