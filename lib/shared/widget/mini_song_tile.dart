import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class MiniSongTile extends StatelessWidget {
  const MiniSongTile({
    super.key,
    required this.tunes,
    required this.index,
    this.onTap,
  });

  final List<Tune> tunes;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tune = tunes[index];
    final playback = context.read<PlaybackBloc>();

    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.currentItem?.path != curr.currentItem?.path,
      builder: (context, state) {
        final isCurrent = state.currentItem?.path == tune.path;

        return InkWell(
          onTap: () {
            onTap?.call();
            playback.add(PlayQueueEvent(tunes, startIndex: index));
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isCurrent
                  ? Theme.of(context).colorScheme.primaryContainer.withAlpha(60)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AlbumArt(
                    id: tune.songId,
                    type: ArtworkType.AUDIO,
                    size: const Size(40, 40),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tune.title.toTitleCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      Text(
                        tune.artists.join(" • "),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
