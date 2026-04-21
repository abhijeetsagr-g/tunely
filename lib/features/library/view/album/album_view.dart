import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/content_view.dart';

class AlbumView extends StatelessWidget {
  const AlbumView({super.key, required this.album});
  final AlbumModel album;
  @override
  Widget build(BuildContext context) {
    return ContentView(
      title: album.album,
      tunes: context.read<LibraryCubit>().getTunesByAlbum(album.id),
      artWidget: AlbumArt(
        artUri: Uri.parse(
          'content://media/external/audio/albumart/${album.id}',
        ),
        size: const Size(300, 300),
      ),
    );
  }
}
