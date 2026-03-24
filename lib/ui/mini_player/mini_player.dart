import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/ui/common/album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      // buildWhen: (prev, curr) =>
      //     prev.currentSong != curr.currentSong ||
      //     prev.isPlaying != curr.isPlaying,
      builder: (context, state) {
        final tune = state.currentSong;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: context.watch<ThemeCubit>().state.mode == .dark
                  ? Colors.white
                  : Colors.black,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                AlbumArt(
                  id: tune?.songId ?? 0,
                  size: Size(48, 48),
                  type: .AUDIO,
                ),

                const SizedBox(width: 12),

                /// Title + Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tune?.title ?? "No Song Playing",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        tune?.artist ?? "No artist",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                /// Play / Pause
                IconButton(
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  onPressed: () {
                    context.read<PlaybackBloc>().add(
                      state.isPlaying ? Pause() : Play(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
