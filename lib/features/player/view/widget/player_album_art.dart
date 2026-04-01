import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

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
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(80),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: QueryArtworkWidget(
                        id: tune.songId!,
                        type: .AUDIO,
                        artworkFit: BoxFit.cover,
                        keepOldArtwork: true,
                        artworkBorder: BorderRadius.circular(16),
                        nullArtworkWidget: Container(
                          color: Colors.grey.shade900,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(child: Icon(Icons.music_note, size: 100)),
          ),
        );
      },
    );
  }
}
