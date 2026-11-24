import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utils/fur_artist_name.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';
import 'package:tunely/shared/widget/pressable_scale.dart';

class QueueSongTile extends StatelessWidget {
  const QueueSongTile({
    super.key,
    required this.tune,
    required this.index,
    this.reorderIndex,
  });

  final Tune tune;
  final int index;
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playback = context.read<PlaybackBloc>();
    final missing = playback.state.missingPaths.contains(tune.path);

    return Dismissible(
      key: ValueKey(tune.path),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (missing) return false;
          playback.add(
            ChangeQueueOrder(
              oldIndex: index,
              newIndex: playback.state.currentIndex! + 1,
            ),
          );
          return false;
        }
        return !missing;
      },
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        context.read<PlaybackBloc>().add(RemoveQueueItemAtEvent(index));
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.skip_next,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),

      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.remove_circle_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),

      child: PressableScale(
        onTap: () =>
            context.read<PlaybackBloc>().add(SkipToQueueItemEvent(index)),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

          enabled: !missing,
          leading: Opacity(
            opacity: missing ? 0.35 : 1,
            child: AlbumArt(artUri: tune.artUri, size: const Size(46, 46)),
          ),
          title: Text(
            tune.title.toTitleCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              color: missing ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            formatArtistName(
              context.read<ManagementCubit>().state.artistDelimiters,
              tune.artist,
            ),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
          trailing: reorderIndex == null
              ? null
              : ReorderableDragStartListener(
                  index: reorderIndex!,
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
