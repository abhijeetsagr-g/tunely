import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/extracted_gradient_container.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/session/cubit/session_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/core/utlis/fur_duration.dart';

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
        Duration position;
        if (isActive) {
          tune = playbackState.currentItem;
          position = playbackState.position;
        } else {
          final session = context.read<SessionCubit>().state;
          if (session == null || session.tunePaths.isEmpty) {
            return const SizedBox.shrink();
          }
          tune = tuneMap[session.tunePaths[session.currentIndex]];
          position = session.position;
        }

        if (tune == null) return const SizedBox.shrink();

        final progress = tune.duration.inMilliseconds > 0
            ? position.inMilliseconds / tune.duration.inMilliseconds
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AlbumArt(
                            size: const Size(64, 64),
                            id: tune.songId,
                            type: ArtworkType.AUDIO,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withAlpha(30),
                                    ),
                                    child: Text(
                                      playbackState.isPlaying
                                          ? 'Now Playing'
                                          : 'Continue Listening',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tune.title.toTitleCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
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
                                          .withAlpha(120),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(80),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              playbackState.isPlaying
                                  ? Navigator.pushNamed(
                                      context,
                                      AppRoute.player,
                                    )
                                  : context.read<PlaybackBloc>().add(
                                      PlayEvent(),
                                    );
                            },
                            icon: Icon(
                              playbackState.isPlaying
                                  ? Icons.open_in_full_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withAlpha(30),
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDur(position),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer.withAlpha(100),
                                fontSize: 11,
                              ),
                        ),
                        Text(
                          formatDur(tune.duration),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer.withAlpha(100),
                                fontSize: 11,
                              ),
                        ),
                      ],
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
