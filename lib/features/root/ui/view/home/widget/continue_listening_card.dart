import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/extracted_gradient_container.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class ContinueListeningCard extends StatelessWidget {
  const ContinueListeningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.currentItem != curr.currentItem ||
          prev.position != curr.position ||
          prev.duration != curr.duration,
      builder: (context, playbackState) {
        final isActive = playbackState.currentItem != null;

        final libraryState = context.read<LibraryCubit>().state;
        if (libraryState is! LibraryLoaded) return const SizedBox.shrink();

        final tuneMap = {for (final t in libraryState.tunes) t.path: t};

        late Tune? tune;
        if (isActive) {
          tune = playbackState.currentItem;
        } else {
          final session = context.read<SessionCubit>().state;
          if (session == null || session.tunePaths.isEmpty) {
            return const SizedBox.shrink();
          }
          tune = tuneMap[session.tunePaths[session.currentIndex]];
        }

        if (tune == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GestureDetector(
            onTap: () {
              if (isActive) return;
              final session = context.read<SessionCubit>().state;
              if (session == null) return;
              final queue = session.tunePaths
                  .map((p) => tuneMap[p])
                  .whereType<Tune>()
                  .toList();
              if (queue.isEmpty) return;
              context.read<PlaybackBloc>().add(
                RestoreSessionEvent(
                  queue: queue,
                  currentIndex: session.currentIndex,
                  position: session.position,
                  shuffleEnabled: session.shuffleEnabled,
                  repeatMode: session.repeatMode,
                  speed: session.speed,
                ),
              );
              context.read<PlaybackBloc>().add(PlayEvent());
            },
            child: ExtractedGradientContainer(
              songId: tune.songId,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AlbumArt(
                        id: tune.albumId ?? 0,
                        size: const Size(56, 56),
                        type: ArtworkType.ALBUM,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isActive ? 'Now Playing' : 'Continue Listening',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withAlpha(60),
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tune.title.toTitleCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatArtistName(
                              context
                                  .read<ManagementCubit>()
                                  .state
                                  .artistDelimiters,
                              tune.artist,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withAlpha(60),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive
                            ? Icons.open_in_full_rounded
                            : Icons.play_arrow_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
