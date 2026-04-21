import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:tunely/features/library/cubit/library_cubit.dart';

import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({super.key, required this.artist, required this.size});

  final Artist artist;
  final Size size;

  Future<String?> _fetchArtistImage() async {
    try {
      final url = Uri.parse(
        'https://api.deezer.com/search/artist?q=${Uri.encodeComponent(artist.artist)}',
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['picture_medium'];
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryCubit>();

    Uri? artUri;

    if (library.state is LibraryLoaded) {
      final state = library.state as LibraryLoaded;

      final tune = state.tunes
          .where((e) => e.artistId == artist.artistId)
          .cast<Tune?>()
          .firstWhere((e) => e != null, orElse: () => null);

      artUri = tune?.artUri;
    }

    final fallback = AlbumArt(artUri: artUri, size: size);

    return FutureBuilder<String?>(
      future: _fetchArtistImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return fallback;
        }

        final imageUrl = snapshot.data;

        if (imageUrl == null) return fallback;

        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        );
      },
    );
  }
}
