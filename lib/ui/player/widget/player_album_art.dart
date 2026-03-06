import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/album_art.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class PlayerAlbumArt extends StatelessWidget {
  const PlayerAlbumArt({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.currentSong != curr.currentSong,
      builder: (context, state) {
        final tune = state.currentSong;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 1,
            child: tune != null
                ? AlbumArt(
                    id: tune.albumId!,
                    size: Size(120, 120),
                    type: .ALBUM,
                  )
                : const Center(child: Icon(Icons.music_note, size: 100)),
          ),
        );
      },
    );
  }
}
