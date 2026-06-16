import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/utlis/show_snackbar.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playlist/view/widget/playlist_dialogs.dart';
import 'package:tunely/shared/model/tune.dart';

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.onPressed, required this.icon});
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class PlaylistActionRowSliver extends StatelessWidget {
  const PlaylistActionRowSliver({
    super.key,
    required this.tunes,
    required this.playlist,
    this.isEditing = false,
  });

  final List<Tune> tunes;
  final PlaylistModel playlist;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  onPressed: tunes.isEmpty
                      ? null
                      : () => context
                          .read<PlaybackBloc>()
                          .add(PlayQueueEvent(tunes, startIndex: 0)),
                  icon: Icons.play_arrow_rounded,
                ),
                _ActionButton(
                  onPressed: tunes.isEmpty
                      ? null
                      : () => context
                          .read<PlaybackBloc>()
                          .add(ShuffleAllEvent(tunes)),
                  icon: Icons.shuffle_rounded,
                ),
                _ActionButton(
                  onPressed: tunes.isEmpty
                      ? null
                      : () {
                          for (final tune in tunes.reversed) {
                            context.read<PlaybackBloc>().add(
                              PlayAfterThisEvent(tune),
                            );
                          }
                          showFlushbar(context, 'Playing next...');
                        },
                  icon: Icons.skip_next_rounded,
                ),
                _ActionButton(
                  onPressed: tunes.isEmpty
                      ? null
                      : () {
                          context.read<PlaybackBloc>().add(
                            AddQueueItemsEvent(tunes),
                          );
                          showFlushbar(context, 'Added to queue');
                        },
                  icon: Icons.queue_music_rounded,
                ),
              ],
            ),
          ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showAddSongsSheet(context, playlist),
                  icon: const Icon(Icons.library_music_outlined, size: 18),
                  label: const Text('Add Songs'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
