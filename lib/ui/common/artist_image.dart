import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/logic/provider/artist_image/artist_image_cubit.dart';
import 'package:tunely/ui/common/album_art.dart';

class ArtistImage extends StatefulWidget {
  const ArtistImage({
    super.key,
    required this.artistName,
    required this.artistId,
    required this.size,
    this.borderRadius = 8,
  });

  final String artistName;
  final int artistId;
  final double size;
  final double borderRadius;

  @override
  State<ArtistImage> createState() => _ArtistImageState();
}

class _ArtistImageState extends State<ArtistImage> {
  late final ArtistImageCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ArtistImageCubit()..load(widget.artistName);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistImageCubit, ArtistImageState>(
      bloc: _cubit,
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: switch (state) {
            ArtistImageLoaded() => CachedNetworkImage(
              imageUrl: state.url,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              placeholder: (_, _) => _fallback(),
              errorWidget: (_, _, _) => _fallback(),
            ),
            _ => _fallback(),
          },
        );
      },
    );
  }

  Widget _fallback() {
    return AlbumArt(
      id: widget.artistId,
      size: Size(widget.size, widget.size),
      type: ArtworkType.ARTIST,
    );
  }
}
