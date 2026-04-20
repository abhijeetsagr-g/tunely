import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/widget/album_art.dart';

class PlayerAlbumArt extends StatelessWidget {
  const PlayerAlbumArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (previous, current) =>
          previous.currentItem != current.currentItem,
      builder: (context, state) {
        final tune = state.currentItem;
        return AlbumArt(artUri: tune?.artUri, size: Size(320, 320));
      },
    );
  }
}
