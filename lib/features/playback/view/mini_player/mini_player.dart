import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/widget/album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.currentItem != curr.currentItem ||
          prev.isPlaying != curr.isPlaying,
      builder: (context, state) {
        final tune = state.currentItem;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoute.player),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).brightness == .dark
                    ? Colors.white
                    : Colors.black,
              ),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  AlbumArt(artUri: tune?.artUri, size: Size(48, 48)),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          tune?.title.toTitleCase() ?? "No Song Playing",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        Text(
                          formatArtistName(
                            context
                                .read<ManagementCubit>()
                                .state
                                .artistDelimiters,
                            tune?.artist ?? "No Song Found",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    onPressed: () {
                      context.read<PlaybackBloc>().add(
                        state.isPlaying ? PauseEvent() : PlayEvent(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
