import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widgets/album_art.dart';

class ArtistImage extends StatelessWidget {
  const ArtistImage({
    super.key,
    required this.artistName,
    required this.size,
    required this.borderRadius,
  });

  final String artistName;
  final Size size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final artistId = context.read<LibraryCubit>().artistIdByName(artistName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AlbumArt(id: artistId ?? 0, size: size, type: ArtworkType.ARTIST),
    );
  }
}
