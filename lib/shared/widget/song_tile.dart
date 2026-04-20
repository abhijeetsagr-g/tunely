import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.tunes, required this.index});
  final List<Tune> tunes;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tune = tunes[index];
    final playback = context.read<PlaybackBloc>();

    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.currentItem?.path != curr.currentItem?.path ||
          prev.position != curr.position ||
          prev.duration != curr.duration,
      builder: (context, state) {
        final isCurrent = state.currentItem?.path == tune.path;
        final progress = isCurrent ? _calcProgress(state) : 0.0;

        return InkWell(
          onTap: () => playback.add(PlayQueueEvent(tunes, startIndex: index)),
          child: Stack(
            children: [
              // Progress fill
              if (isCurrent)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

              // Tile content
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: AlbumArt(
                  // id: tune.songId ?? 0,
                  artUri: tune.artUri,
                  size: Size(46, 46),
                  // type: ArtworkType.AUDIO,
                ),
                title: Text(
                  tune.title.toTitleCase(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: Text(
                  formatArtistName(
                    context.read<ManagementCubit>().state.artistDelimiters,
                    tune.artist,
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                ),
                trailing: const Icon(Icons.more_horiz, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calcProgress(PlaybackState state) {
    final duration = state.duration;
    if (duration == null || duration.inMilliseconds == 0) return 0.0;
    return (state.position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }
}
