import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utlis/fur_artist_name.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class QueueSongTile extends StatelessWidget {
  const QueueSongTile({super.key, required this.tune, required this.index});

  final Tune tune;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(tune.path),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.read<PlaybackBloc>().add(PlayAfterThisEvent(tune));
          return false;
        }
        return true;
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

      child: InkWell(
        onTap: () {
          context.read<PlaybackBloc>().add(SkipToQueueItemEvent(index));
        },
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: AlbumArt(artUri: tune.artUri, size: const Size(46, 46)),
          title: Text(
            tune.title.toTitleCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            formatArtistName(
              context.read<ManagementCubit>().state.artistDelimiters,
              tune.artist,
            ),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
          trailing: Icon(
            Icons.drag_handle_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
