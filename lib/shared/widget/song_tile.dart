import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/song_tile_sheet.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.tunes,
    required this.index,
    this.onTap,
    this.trailing,
  });

  final List<Tune> tunes;
  final int index;
  final VoidCallback? onTap;
  final Widget? trailing;

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

        final progress =
            isCurrent &&
                state.duration != null &&
                state.duration!.inMilliseconds > 0
            ? (state.position.inMilliseconds / state.duration!.inMilliseconds)
                  .clamp(0.0, 1.0)
            : 0.0;

        return InkWell(
          onTap: () {
            onTap?.call();
            playback.add(PlayQueueEvent(tunes, startIndex: index));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
                          ).colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: AlbumArt(
                    id: tune.songId,
                    type: ArtworkType.AUDIO,
                    size: Size(46, 46),
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
                    tune.artists.join(" • "),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                  ),
                  trailing:
                      trailing ??
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () => showSongTileSheet(context, tune),
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
