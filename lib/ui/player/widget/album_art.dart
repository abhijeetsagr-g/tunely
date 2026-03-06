import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/logic/bloc/playback/playback_bloc.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({super.key});

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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              clipBehavior: Clip.hardEdge,
              child: tune != null
                  ? QueryArtworkWidget(
                      key: ValueKey(tune.songId),
                      id: tune.songId!,
                      type: ArtworkType.AUDIO,
                      artworkFit: BoxFit.cover,
                      keepOldArtwork: true,
                      nullArtworkWidget: const Center(
                        child: Icon(Icons.music_note, size: 100),
                      ),
                    )
                  : const Center(child: Icon(Icons.music_note, size: 100)),
            ),
          ),
        );
      },
    );
  }
}
